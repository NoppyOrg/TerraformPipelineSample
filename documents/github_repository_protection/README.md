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
私見ですが、5-10名前後の小規模の開発チームでのプロジェクトで、あまりガチガチに役割を分離せず柔軟に運用するけど、締めるところは締めるという場合は、以下の感じかと妄想しています。

| ロール | 割り当て先 | ざっくりした役割 |
| ----- | -------- | -------------- |
| `Admin`|そのプロジェクトの責任者&副責任者|レポジトリのSettingでの設定変更。普段は使わない。|
|`Maintain`|チームコアメンバー|mainリポジトリへのマージ、および`development`, `staging`, `production`へのマージ(=各環境へのリリース)は、コアメンバーに限定する(*1)|
| `Write`|チームメンバー|開発全般|
- (*1)プロジェクトの特性や状況に応じて、`production`のみ制限などのバリエーションは考えられる。


ただ上記の場合、機密情報を扱うシステムやビジネスに直結する基幹業務など、開発環境と本番環境の分離が重視されるセキュアなシステムでは、本番・開発の権限分離が不十分なので追加の検討が必要になると思います。具体的には、`production`とそれ以外の分離が必要になります。

以下に、本番・開発分離の案を考えたものを挙げます。

- 本番・開発の分離案
  - 案1: `production`ブランチのマージは`Admin`ロールに限定する
    - 本番リリースは`Admin`ロールとし、`Maintain`ロールは`staging`ブランチまでにし、権限分離で本番・開発の分離とする案。
    - Pros: 一番リーズナブルかなとは思う。
    - Cons: 
      - 責任者の負担: 責任者が必ずリリースする必要があるため、管理者の負担が高まるや管理者不在の時のリリースができない、管理者が技術に疎いと運用が難しい可能性がある。
      - `Admin`に対する抑制ができない: `Admin`ロールは、任意に`production`ブランチの操作ができてしまう。
      - レポジトリ&NW的な分離ができない: レポジトリは全体で一つになる。またGitHub操作元のクライアントのIP制限はOrganization単位となるため、本番と開発環境で作業環境の分離が、運用ベースに委ねられる。
  - 案2: 本番(`production`)はレポジトリを分離する
    - 本番用にレポジトリを分離し、本番レポジトリから開発用レポジトリの`staging`ブランチの内容を取り込み本番デプロイする。(例えば本番レポジトリのGitHub Actionで開発レポジトリの`staging`ブランチの内容をcloneしてマージするとか)。さらに、本番レポジトリの一連の作業を完全自動化して手動作業を排除することでセキュリティは高められる。
    - Pros: 本番・開発の分離が十分できる
    - Cons: 
      - 実装の難易度: 複雑で作り込みが大変。特に本番リポジトリでの`staging`コード取り込みと、一連の作業の完全自動化の実装
      - GitHub Organizationレベルでの分離: GitHub Organizationレベルでは単一となる。
  - 案3(案2'): 案2に加えて、GitHub Organizationレベルから本番・開発で分離する
    - GitHub Organizationレベルで本番・開発を分離。本番用のGitHub Organizationでは、IP許可を本番アクセス環境からのIPに限定する。
    - Pros: 最もセキュア
    - Cons: Organizationレベルとなると、単一のブロジェクトでは難しく、組織全体での取り組みが必要となる


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

## 3. (オプション)コードオーナーの設定
コードオーナーの設定を行うと、Pull Request発行時にレビュー依頼が自動で届くようになります。また、次に述べつルールセットでコードオーナーによる承認を強制することができます。

ルールセットで`コードオーナーによる承認を強制する`設定を有効化する場合は、コードオーナーの設定を行います。

<設定方法>
1. `.github/`ディレクトリに `CODEOWNERS` ファイルを作成します。
2. ファイルにコードオーナーを指定します(以下に例を示す)。コードオーナーの設定方法は[こちらのドキュメント](https://docs.github.com/ja/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#example-of-a-codeowners-file)を参考にしてください。
    ```
    * @team-leads
    ```

<参考>
- [コードオーナーについて](https://docs.github.com/ja/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)


## 4. ブランチ保護ルールの設定
### a. ブランチルールの概要
ブランチに対して、ブランチの削除禁止や直接のpush禁止(必ずpull request経由でマージする)などのルールを設定することで、開発者がオペレーションミスなどでブランチを壊さないように保護します。

### b. ブランチ保護ルールの種類
GitHubのブランチ保護は、(1)`classic branch protection rule`と、(2)`ruleset`の二種類があります。また(2)`ruleset`については、対象に合わせて、(i)`branch ruleset`, (ii)`tag ruleset`, (iii)
`push ruleset`の３つのルールセットがあります。

|区分|ルール名|保護対象|GitHub Free|GitHub 有償プラン|
|---|-------|-------|-------|-------|
|Classic|classic branch protection rule|branch|利用可(制限あり)|利用可|
|ruleset|branch ruleset|branch|利用可(制限あり)|利用可|
||tag ruleset|tag|利用可(制限あり)|利用可|
||Push ruleset|push|NG|利用可|

ブランチに対する保護について今回は、GitHubからのアナウンスはありませんが、ゆくゆくはclassicからrulesetに移行するのかと妄想し、(2)`branch ruleset`を採用することとします。

### c. ブランチルールセットの設定
#### i.はじめに
保護の対象ブランチは、gitlab-flowのブランチ戦略の場合、少なくとも開発のメインブランチとなる`main`と、各環境用のブランチ(`development`, `staging`, `production`)になり、これらのブランチをルールセットで保護することになります。

ブランチルールセットの詳細は以下のドキュメントを参照してください。
- [GitHubドキュメント:ブランチ保護ルールについて](https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches#about-branch-protection-rules)

またこちらのbranch rulesetの設定は、[こちらのブログ](https://zenn.dev/kuritify/articles/github-rulesets)の内容を参考にさせていただきました。

#### ii.ブランチルールセットの設定単位
結論から言うと、設定内容が重複してしまいますが、**ブランチ毎にブランチルールセットを設定するのが良さそう**です。

どのブランチにルールセットを適用するかは、ルールセット内の`Target branches`で指定します。指定では`fnmatch`によるファイルマッチのライブラリを利用しておりワイルドカード(`*`)は利用できますが、正規表現は利用できないです。そのため、複数のブランチを指定すると言うのが難しく、結果としてブランチごとにルールを作成した方が良いと言うことになります。

なお、ルールセットの設定ではexport/importが使えるので(2025.2月時点では、Previewですが)、一回作ったルールセットをexportしてそれをimportして複製することで、複数のブランチにミスなくルールセットが設定できます。

#### iii.保護をするブランチ
以下のブランチに対してルールセットを設定して、ブランチを保護します。
- `main` : 開発のメインブランチ
- `development` : 開発環境へのデプロイ用ブランチ
- `staging` : ステージング環境へのデプロイ用ブランチ
- `production` : 本番環境へのデプロイ用ブランチ

#### iv.設定するルール

[こちらのブログ](https://zenn.dev/kuritify/articles/github-rulesets)の内容に倣い、各ブランチに対して以下の２つのルールセットを適用します。

- `<branch名>-all-user-rule` : ブランチ削除禁止、pull requestの必須化など全ユーザーに適用するルールを設定します。
- `<branch名>-maintainer-user-rule` : bypassで設定したユーザーのみブランチ更新を許可します(許可したい人をbypassに指定して、Restrict updatesのみ有効化する)


##### `<branch名>-all-user-rule`の設定内容

<table>
<tr><th>ルール</th><th>サブルール</th><th>ルールの説明</th></tr>
<tr><td colspan=2><b>restrict deletions</b></td><td>ブランチの削除を制限(ルールセット作成時にデフォルトでON)</td>
<tr><td colspan=2><b>Require a pull request before merging</b></td><td>ージの際にPull Requestを要求する(結果として、直接のPushができなくなる)</td>
 <tr><td></td><td><b>Required approvals</b></td><td>Pull requestのマージの際、設定した人数以上の承認が必要になる。５-名前後の体制なら、一人か多くて二人、10名レベルになれば２名という感じか？</td></tr>
 <tr><td></td><td><b>Dismiss stale pull request approvals when new commits are pushed</td><td>承認後に元のブランチで新しいpushがあった場合は、既存の承認は無効化する</td></tr>
 <tr><td></td><td><b>Require review from Code Owners</td><td>「(オプション)コードオーナーの設定」を設定した場合は、こちらを有効化する</td></tr>
<tr><td></td><td><b>Require approval of the most recent reviewable push</b></td><td> 最新のレビュー対象のPushに対して、Pushした人と異なる人が承認する必要がある</td></tr>
 <tr><td></td><td><b>RRequire conversation resolution before merging</b><td>全てのconversationが解決済みである必要がある</td></tr>
 <tr><td></td><td><b>Request pull request review from Copilot</td><td>Pull requestでCopilotのレビューを要求する</td></tr>
<tr><td colspan=2><b>Require status checks to pass</b><td>指定したStatus Checkをパスしていることを要求する</td></tr>
 <tr><td></td><td><b>Status checks that are required</b></td><td>パスを必須とするチェックを指定する。GitHub Actionで設定したCode Testでは
 開発・ステージング・本番環境の3つの環境のチェックを並列で行い、全てのチェックがパスすることをテスト結果の期待値としています。この項目ではブランチごとに、チェック対象の環境が変わります。(dev -> staging -> productionの順に適用するため、適用済みの環境を再テストしても意味がないため)
<ul>
<li>production環境
  <ul>
    <li>Code Test (production)</li>
  </ul>
</li>
<li>staging環境
  <ul>
    <li>Code Test (production)</li>
    <li>Code Test (Staging)</li>
  </ul>
</li>
<li>development & main環境
  <ul>
    <li>Code Test (production)</li>
    <li>Code Test (Staging)</li>
    <li>Code Test (development)</li>
  </ul>
</li>
</ul>
</td></tr>
<tr><td colspan=2><b>Block force pushes</b><td>force pushを禁止する（デフォルトで有効）</td></tr>
<tr><td colspan=2><b>Require code scanning results</td><td>指定したコードチェック(ここではCodeQL)に通過することを必須とする</td></tr>
</table>

##### `<branch名>-maintainer-user-rule`の設定内容

- Bypass list
  - マージを許可するユーザー、チーム、またはロールを登録する。サンプルではロールで`Repository Admin`と`Maintain`ロールを指定している。
- ルール

<table>
<tr><th>ルール</th><th>サブルール</th><th>ルールの説明</th></tr>
<tr><td colspan=2><b>Restrict updates</b></td><td>Bypass listに設定したユーザーやチーム以外の人のブランチの更新を制限する</td>
</table>

##### <参考>
- [うん。これで事故るならしょうがない。GitHub ルールセットでGitの操作ミスと無縁になる](https://zenn.dev/kuritify/articles/github-rulesets)
- [GitHubドキュメント:ルールセットで使用できるルール](https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)

- [Blog:Branch protectionsでできること](https://zenn.dev/dzeyelid/articles/ba5b17765efd8d#branch-protections%E3%81%A7%E3%81%A7%E3%81%8D%E3%82%8B%E3%81%93%E3%81%A8) : ルールセットが一覧表で整理されていてみやすいです。

#### v.ルールセットの設定方法

+ レポジトリで`Settings`タブに入り、サイドバーから`Rule`->`Ruleset`を選択
+ 右上の緑ボタン`New Ruleset`から新しいルールを作成する
  + 新規に作成したい場合はプルダウンから`New branch ruleset`を選択
  + 既存のjson設定ファイルをimportする場合は`import a ruleset`を選択

import用のサンプルJSONを以下のフォルダに入れているので参考にしてください。
- `src/github`

5. (有償プランのみ)プッシュルールセットによる特定ファイルパスの保護

GitHubの有償プランを利用している場合、`Push ruleset`を利用することができます。プッシュルールセットで、特定のファイルパスへのpushを制限することができます。
この設定を利用することで、`.github/workflow`や`.ghthub/CODEOWNERS`を保護することができます。

詳細は以下のドキュメントを参照ください。
- [ファイルパスを制限する](https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets#restrict-file-paths)
