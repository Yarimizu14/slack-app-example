# slack-app-example

- [Slash Command](https://api.slack.com/interactivity/slash-commands)
- [Shortcut](https://api.slack.com/interactivity/shortcuts/using#global_shortcuts)

を実装したSlack Appのサンプルです。

Slash CommandまたはShortcut経由でProjectリソースとSlack Channelを紐づけることができます。
紐付けられたProject下のJobリソースが作成されるたびにbotユーザーが対応するSlackチャネルに通知を行います。

### Slack OAuth 2.0

Slack Appの配布には、[Slack OAuth 2.0](https://api.slack.com/legacy/oauth#authenticating-users-with-oauth__the-oauth-flow)の認証フローを実装する必要があります。

omniauthのプラグイン[ginjo/omniauth-slack](https://github.com/ginjo/omniauth-slack)を使って実装しています。

```ruby
provider :slack, ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], scope:'links:read,links:write,commands,chat:write,team:read'
```

#### OAuth 2.0のScopeについて

以下のScopeでPermissionを取得しています。

<img src="https://github.com/Yarimizu14/slack-app-example/blob/master/images/oauth-scopes.png" width="500">

スコープに`chat:write`を含めることでSlack Bot Tokenでチャネルへの投稿ができるようになります。

`incoming-webhook`をスコープに含めることで認証時にWebHook URLを取得することができますが、
選択できるのは1チャネルのみになってしまい、ユーザーが複数のチャネルで通知を受け取るような設定ができなくなってしまいます。

#### Endpointの実装について

##### リダイレクト用Endpoint

- リダイレクト前にユーザーが登録済みかを確認します
    - (Callback用EndpointでUsersテーブルの `slack_id` カラムでSlackのユーザーIDを紐付けるため)
- ユーザーをSlackの認証画面へリダイレクトします

##### Callback用Endpoint

```
GET /auth/slack/callback
```

https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/auth_controller.rb#L9-L26

- 認証後のCallback Endpointで[こちら](https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/auth_controller.rb#L31-L49)の情報が取得できます
    - `Slack User ID`: ユーザーテーブルのカラムに追加します。対応するユーザーIDはセッションから取得します。
    - `Slack Team ID`: Organizationテーブルのカラムに追加し認証ユーザーが所属するOrganizationとSlackのTeamを連携させます。
    - `Slack Bot Token`: Organizationテーブルのカラムに追加しSlackへの投稿などの認証に使用します。

### Slash Command

[Slash Command](https://api.slack.com/interactivity/slash-commands)でコマンドが実行されたSlackチャネルとリソースを紐付けます。

<img src="https://github.com/Yarimizu14/slack-app-example/blob/master/images/slash-command.png" width="500">

#### Request URL

Slash Command実行時に呼び出されるエンドポイントが必要になります。

```
POST /slack/commands
```

https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/slack/commands_controller.rb#L6-L26

- [Slack側から投げられるParameter](https://api.slack.com/interactivity/slash-commands#app_command_handling)に、`user_id`・`team_id`が含まれるため、OAuthの認証フローで紐付けたUser、Organizationを元に認可範囲を絞ります。
- ユーザーが入力したコマンドをパースしサブコマンドのような形で処理を分岐します。
- Slack連携の設定をDBに書き込みまたは削除します
- `response_url`にPOSTし、Slash Commandに対する返答を送ります

### Shortcut (global)

[Shortcut](https://api.slack.com/interactivity/shortcuts/using#global_shortcuts)で起動するフォームによりSlackチャネルと指定されたリソースを紐付けます。

<img src="https://github.com/Yarimizu14/slack-app-example/blob/master/images/invoke-shortcut.png" width="500">

⚡️アイココンから `shortcut`を起動します。

<img src="https://github.com/Yarimizu14/slack-app-example/blob/master/images/slack-shortcut.png" width="500">

起動したモーダルでSlackのチャネルとリソースを選択してもらうことで紐付けを行います。

> These type of shortcuts are intended to trigger workflows that can operate without the context of a channel or message.

API Endpointにチャネルの情報が渡らないので、ユーザーにチャネル選択してもらう必要があります。

#### Request URL

Slash Command実行時に呼び出されるエンドポイントが必要になります。

```
POST /slack/shortcuts
```

https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/slack/shortcuts_controller.rb

Payloadに含まれる `type`によって以下の2種類のリクエストを判別して処理します。

1. Shortcut起動時のリクエストの処理 - `type: shortcut`

2. モーダルのフォーム送信リクエスト - `type: view_submission`

#### Shortcut起動時のリクエスト

[モーダル表示](https://api.slack.com/surfaces/modals/using#opening)のためのレスポンスを返却します。選択可能な項目を返却するJSONに差し込みます。

#### モーダルのフォーム送信リクエスト

送られてきたPayloadから選択項目を抽出しDBへ格納します。

##### References

- https://github.com/integrations/slack
