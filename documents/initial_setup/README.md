# GitHub Actions および Terraform セットアップ手順

## 構成イメージ
![構成イメージ](github-action-aws-env-diagram.drawio.png)

## 手順概要

本ページでは、GitHub Actions を実行し Terraform の plan までが動作するところまでの設定手順を説明します。
GitHub Actions による CI 環境は大きく以下の流れでセットアップを進めます。

1. 前提の確認
1. Actions および Terraform に必要な AWS リソースの作成
1. Terraform の修正
1. GitHub Actions の動作テスト

## 前提の確認

セットアップの前提として以下が完了していることを確認します。

1. AWS アカウントの初期セットアップが完了していること
1. AWS CLI が利用可能な作業環境であること
   1. AWS CLI のインストールは[こちらを参照](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   1. 設定方法は[こちらを参照](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-quickstart.html)
   1. `AdministratorAccess`権限で実行可能なこと
1. (Option) GitHub CLI が利用可能なこと
   1. GitHub CLI のインストールは[こちらを参照](https://github.com/cli/cli?tab=readme-ov-file#installation)

## Actions および Terraform に必要な AWS リソースの作成

GitHub Actions にて該当 AWS 環境にアクセス可能にするため、OIDC プロバイダーと、Actions から AssumeRole される IAM ロールを作成します。また Terraform で必要となるバックエンド用の S3 バケットとロック用の DynamoDB テーブルを作成します。

具体的には以下のリソースを作成します。

- IAM OIDC プロバイダー: `https://token.actions.githubusercontent.com`
- IAM ロール:
  - `GitHubAction-Deploy-Role`
  - `GitHubAction-Check-Role`
- Terraform のバックエンド
  - S3 バケット: `TunnelVpc-terraform-backend` (\*1)
  - DynamoDB テーブル: `TunnelVpc-terraform-lock-state` (\*2)
- KMS キー(S3 バケット/DynamoDB 暗号化用): `alias/Key-For-Terraform`

(*1) バケット名は、スタック作成時のパラメータで変更可能です。
(*2) テーブル名を変更する場合は、CloudFormation テンプレートの`TableName`部分を更新ください。

## OIDC プロバイダー/IAM ロール/S3 バケット/DynamoDB テーブル作成

### 事前準備

(MacOS の場合のみ)zsh でコメントアウトを有効にする

```shell
setopt interactivecomments
```

共通で利用する環境変数の設定

```shell
PROFILE=default
```

AWS CLI の実行確認

```shell
aws --profile ${PROFILE} sts get-caller-identity
```

環境変数の自動設定

```shell
ACCOUNT_ID=$(aws --profile ${PROFILE} --output text \
    sts get-caller-identity --query 'Account')
echo "<<<<<Check>>>>>"
echo "ACCOUNT_ID=${ACCOUNT_ID}"
```

### OIDC プロバイダーの作成

AWS CLI で OIDC プロバイダーを作成します。(CloudFormation では、ThumbprintList が自動生成されないため CLI を利用)

```shell
aws --profile ${PROFILE} \
    iam create-open-id-connect-provider \
        --url "https://token.actions.githubusercontent.com" \
        --client-id-list "sts.amazonaws.com";
OIDC_PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

# OIDCプロバイダーの確認
aws --profile ${PROFILE} \
    iam get-open-id-connect-provider \
        --open-id-connect-provider-arn "${OIDC_PROVIDER_ARN}"
```

### IAM ロール/KMS/S3 バケット/Dynamodb の作成

CloudFormation を利用し、GitHub Actions からの AWS アクセスおよび Terraform に必要なリソースをデプロイします。

<設定概要>

- テンプレート: `./initial_setup/github_role_s3_dynamodb_for_terraform.yaml`
- スタック名: `github-action-and-terraform-resources`
- パラメータ:
  - `GitHubOrganizationsName` : 本リポジトリの所有者を設定。所有者が組織の場合は GitHub Organization 名を指定。所有者が個別アカウントの場合は、アカウン名を設定する。
  - `OidcProvider`: 作成した OIDC プロバイダーの ARN の指定

CloudFormation のデプロイ

```shell
aws --profile ${PROFILE} cloudformation deploy \
    --stack-name "github-action-and-terraform-resources" \
    --template-file "./initial_setup/setup_github_action.cf.yaml" \
    --parameter-overrides OidcProvider="${OIDC_PROVIDER_ARN}" \
    --capabilities CAPABILITY_NAMED_IAM ;
```

## GitHub 設定

### Actions から AssumeRole する先のロール ARN 設定

`TunnelNetwork`リポジトリの variables にアカウント ID や実行用の IAM ロール名を設定します。
変数は、以下の３つを設定します。

- `AWS_ACCOUNT_ID`: 実行先アカウント ID
- `AWS_IAM_ROLE_NAME_DEPLOY_ROLE`: デプロイ用 IAM ロール名
- `AWS_IAM_ROLE_NAME_CHECK_ROLE`: チェック用 IAM ロール名

<ブラウザでの設定手順>

- (a)GitHub の`TunnelNetwork`リポジトリの`Settings`を開く
- (b)右のメニューから`Secrets and variables`の`Actions`を選択する
- (c)`variables`のタグをクリックして開く
- (d) New repository variable`で以下の３つの変数を作成する
  - AWs アカウント ID
    - `Name`: `AWS_ACCOUNT_ID`
    - `Value`: `<実行先のAWSアカウントの12桁のアカウントID>`
  - Terraform 実行用 IAM ロール名(デプロイ用 IAM ロール)
    - `Name`: `AWS_IAM_ROLE_NAME_DEPLOY_ROLE`
    - `Value`: デプロイした CloudFormation の`setup-github-and-terraform`スタックの出力に出ている`GitHubRoleTerraformDeployRoleName`の値を設定
  - Terraform 実行用 IAM ロール名(チェック用 IAM ロール)
    - `Name`: `AWS_IAM_ROLE_NAME_CHECK_ROLE`
    - `Value`: デプロイした CloudFormation の`setup-github-and-terraform`スタックの出力に出ている`GitHubRoleTerraformCheckRoleName`の値を設定

<GitHub CLI の操作>

TunnelNetwork レポジトリのディレクトリで実施します。

```shell
#CloudFormationスタック出力からのIAMロール名取得
AWS_IAM_ROLE_NAME_DEPLOY_ROLE=$( \
  aws --profile ${PROFILE} --output text \
    cloudformation describe-stacks \
        --stack-name setup-github-and-terraform \
        --query 'Stacks[].Outputs[?OutputKey==`GitHubRoleTerraformDeployRoleName`].[OutputValue]');

AWS_IAM_ROLE_NAME_CHECK_ROLE=$( \
  aws --profile ${PROFILE} --output text \
    cloudformation describe-stacks \
        --stack-name setup-github-and-terraform \
        --query 'Stacks[].Outputs[?OutputKey==`GitHubRoleTerraformCheckRoleName`].[OutputValue]')

echo "AWS_IAM_ROLE_NAME_DEPLOY_ROLE = ${AWS_IAM_ROLE_NAME_DEPLOY_ROLE}"
echo "AWS_IAM_ROLE_NAME_CHECK_ROLE  = ${AWS_IAM_ROLE_NAME_CHECK_ROLE}"


# GitHubのTunnel レポジトリへの指定
gh variable set AWS_ACCOUNT_ID --body ${ACCOUNT_ID}
gh variable set AWS_IAM_ROLE_NAME_DEPLOY_ROLE --body ${AWS_IAM_ROLE_NAME_DEPLOY_ROLE}
gh variable set AWS_IAM_ROLE_NAME_CHECK_ROLE  --body ${AWS_IAM_ROLE_NAME_CHECK_ROLE}
```

## Terraform 修正

### バックエンド設定の変更内容の説明

Terraform のバックエンドで利用する S3 バケットを、CloudFormation で作成したリソースに設定します。
具体的な設定ファイルは以下となります。

- 対象ファイル: `env/development/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket = "CloudFormationスタックの`TerraformBackendSeBucketName`の値を設定"
    key    = "tunnel-vpc/development/terraform.tfstate"
    region = "ap-northeast-1"

    dynamodb_table = "terraform-lock-state"
  }
}
```

<設定箇所>

- `bucket` : CloudFormation`setup-github-and-terraform`スタックの出力の`TerraformBackendSeBucketName`の値を設定
- `dynamodb_table` : CloudFormation`setup-github-and-terraform`スタックの出力の`TerraformLockStateTableName`の値を設定

### 設定値の取得

(1) Terraform backend 用 S3 バケット名称の取得

```shell
echo "TerraformBackendSeBucketName = $( \
  aws --profile ${PROFILE} --output text \
    cloudformation describe-stacks \
        --stack-name setup-github-and-terraform \
        --query 'Stacks[].Outputs[?OutputKey==`TerraformBackendSeBucketName`].[OutputValue]')";
```

(2) Terraform backend の Lock 用 Dynamodb テーブル名の取得

```shell
echo "TerraformLockStateTableName = $( \
  aws --profile ${PROFILE} --output text \
    cloudformation describe-stacks \
        --stack-name setup-github-and-terraform \
        --query 'Stacks[].Outputs[?OutputKey==`TerraformLockStateTableName`].[OutputValue]')";
```

### backend.tf の修正

(1) 修正用ブランチの作成と移動

```shell
 git checkout -b future-modify-backend
```

(2) 修正

エディタな度で、下記ファイルの`bucket = `と`dynamodb_table =`の値を修正する。

- 対象ファイル: `env/development/backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket = "CloudFormationスタックの`TerraformBackendSeBucketName`の値を設定"
    key    = "tunnel-vpc/development/terraform.tfstate"
    region = "ap-northeast-1"

    dynamodb_table = "terraform-lock-state"
  }
}
```

(3) コミット

```shell
git add .
git commit -m 'modify backend'
```

## GitHub Actions での Terraform による環境のデプロイ

```shell
git branch
 git push --set-upstream origin future-modify-backend
```
