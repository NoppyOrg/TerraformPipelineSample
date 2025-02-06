# GitHubでの大規模開発におけるレポジトリ保護手順

大規模な開発プロジェクトでは、レポジトリの保護が重要です。以下は、GitHubでレポジトリを保護するための手順です。


## 1. ユーザーやチームの権限設定

### (GUI)ユーザーやチームの権限設定方法
設定はブラウザからのGUI設定になります。(ghコマンドは見た限りだと機能がなさそう)
手順は以下の通りになります。
- `Settings` -> `Collaborators and teams`に移動
- `Manage access`で、設定したいユーザーまたはチームを指定して、適切なロールを選択し設定

### ロールの指定
ユーザーやチームへの権限付与は、Organizationを利用している場合は、規定のリポジトリロールを利用するのが簡単で良いと思います。
ロールは権限が強い順に、`Admin`, `Maintain`, `Write`, `Triage`, `Read`の5つのロールがあります。
- [Organizationのリポジトリロール](https://docs.github.com/ja/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization#repository-roles-for-organizations)

<参考>
私見ですが、5〜10名規模の開発チームでのプロジェクトで、あまりガチガチに役割を分離せず柔軟に運用するけど、締めるところは締めるという場合は、以下の感じかと妄想しています。

| ロール | 割り当て先 | ざっくりした役割 |
| ----- | -------- | -------------- |
| `Admin`|そのプロジェクトの責任者&副責任者|レポジトリのSettingでの設定変更|
| `Write`|チームメンバー|開発全般&PullReqの承認も含む|
| `Read`|チーム以外のオブザーバー|監査やレビューなど|

## 2. (オプション)Code scanning(CodeQL)の有効化
[CodeQL](https://docs.github.com/ja/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning-with-codeql)は、GitHub が開発したセキュリティチェックを自動化するためのコード分析エンジンです。
CodeQL を使用してコードを分析し、結果を code scanning アラートとして表示することができます。
パブリックポリシーのリポジトリか、[GitHub Advanced Security ](https://docs.github.com/ja/get-started/learning-about-github/about-github-advanced-security)を有効化したGitHub Enterprise CloudのOrganizationに所属するリポジトリに限ります。

ただし、今回のTerraformのHLCコードはスキャン対象コードでないので、有効化してもあまり効果はないかもです。
GitHub Actionのセキュリティチェックはしてくれるので、使いたい場合は使うという感じで良いかと思います。

### (GUI)Code scanning(CodeQL)の有効化 手順
設定手順は、[こちらのドキュメント](https://docs.github.com/ja/code-security/code-scanning/enabling-code-scanning/configuring-default-setup-for-code-scanning)を参照。

<簡易手順>
1. 該当リポジトリで`Setting`タブに移動
1. 左のサイドバーの`Security`セクションから、`Code security`に入る
1. `Code scanning`セックションで`Set up`を選び`Default`を選択
1. `Enable CodeQL`の緑ボタンを押して有効化

## 3. ブランチ保護ルールの設定
### a. ブランチルールセット
#### i. ブランチルールの概要
ブランチに対して、ブランチの削除禁止や直接のpush禁止(必ずpull request経由でマージする)などのルールを設定することで、開発者がオペレーションミスなどでブランチを壊さないように保護します。

対象ブランチは、gitlab-flowのブランチ戦略の場合、少なくとも開発のメインブランチとなる`main`と、各環境用のブランチ(`development`, `staging`, `production`)は、ルールセットでブランチ保護するのが良いと思います。

ブランチルールセットの詳細は以下のドキュメントを参照してください。
- [GitHubドキュメント:ブランチ保護ルールについて](https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#about-branch-protection-rules)

#### ii.ブランチルールセットの設定単位
結論から言うと、設定内容が重複してしまいますが、**ブランチ毎にブランチルールセットを設定するのが良さそう**です。

どのブランチにルールセットを適用するかは、ルールセット内の`Target branches`で指定します。指定では`fnmatch`によるファイルマッチのライブラリを利用しておりワイルドカード(`*`)は利用できますが、正規表現は利用できないです。そのため、複数のブランチを指定すると言うのが難しく、結果としてブランチごとにルールを作成した方が良いと言うことになります。

なお、ルールセットの設定ではexport/importが使えるので(2025.2月時点では、Previewですが)、一回作ったルールセットをexportしてそれをimportして複製することで、複数のブランチにミスなくルールセットが設定できます。

#### iii.設定するルール


#### iiii.ルールセットの設定方法




1. レポジトリの設定ページに移動します。
2. 「Branches」タブを選択します。
3. 「Add rule」をクリックし、保護したいブランチ名を指定します。
4. 必要な保護オプションを選択します（例：プルリクエストのレビューが必要、CIの成功が必要など）。







## 2. コードオーナーの設定
1. レポジトリのルートに `CODEOWNERS` ファイルを作成します。
2. ファイルにコードオーナーを指定します。例：
    ```
    * @team-leads
    ```
3. コードオーナーは、指定されたファイルやディレクトリに対する変更をレビューする責任があります。

## 3. セキュリティポリシーの設定
1. レポジトリの設定ページに移動します。
2. 「Security & analysis」タブを選択します。
3. 「Enable」ボタンをクリックして、セキュリティ機能を有効にします（例：Dependabot alerts、セキュリティスキャンなど）。

## 4. アクセス権限の管理
1. レポジトリの設定ページに移動します。
2. 「Manage access」タブを選択します。
3. チームや個人に対して適切なアクセス権限を設定します（例：読み取り専用、書き込み可能など）。

## 5. 定期的な監査
1. レポジトリのアクティビティログを定期的に確認します。
2. 不審なアクティビティがないか監視します。
3. 必要に応じてアクセス権限を見直します。

これらの手順を実施することで、GitHubレポジトリのセキュリティを強化し、大規模開発プロジェクトを安全に進めることができます。


test2