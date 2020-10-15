# slack-app-example

### Slack OAuth 2.0

omniauthのプラグイン[ginjo/omniauth-slack](https://github.com/ginjo/omniauth-slack)を使って実装しています。

```ruby
provider :slack, ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], scope:'links:read,links:write,commands,chat:write,team:read'
```

[Slack OAuth 2.0](https://api.slack.com/legacy/oauth#authenticating-users-with-oauth__the-oauth-flow)の認証フローを実装します。

#### OAuth 2.0のScopeについて

以下のScopeでPermissionを取得しています。

![OAuth Scope](https://github.com/Yarimizu14/slack-app-example/blob/master/images/oauth-scopes.png)

スコープに`chat:write`を含めることでSlack Bot Tokenでチャネルへの投稿ができるようになります。

`incoming-webhook`をスコープに含めることで認証時にWebHook URLを取得することができますが、
選択できるのは1チャネルのみになってしまい、ユーザーが複数のチャネルで通知を受け取るような設定ができなくなってしまいます。

#### Endpointの実装について

##### リダイレクト用Endpoint

- リダイレクト前にユーザーが登録済みかをリダイレクト前に確認します
    - (Callback用EndpointでUsersテーブルの `slack_id` カラムでSlackのユーザーIDを紐付けるため)
- ユーザーをSlackの認証画面へリダイレクトします

##### Callback用Endpoint

```
GET /auth/slack/callback
```

https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/auth_controller.rb#L9-L26

- 認証後のCallback Endpointで[こちら](https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/auth_controller.rb#L31-L49)の情報が取得できます
    - Slack User ID: ユーザーテーブルのカラムに追加します。対応するユーザーIDはセッションから取得します。
    - Slack Team ID: Organizationテーブルのカラムに追加し認証ユーザーが所属するOrganizationとSlackのTeamを連携させます。
    - Slack Bot Token: Organizationテーブルのカラムに追加しSlackへの投稿などの認証に使用します。

### Slash Command

[Slash Command](https://api.slack.com/interactivity/slash-commands)

![slash-command-setting](https://github.com/Yarimizu14/slack-app-example/blob/master/images/slash-command.png)

#### Request URL

Slash Command実行時に呼び出されるエンドポイントが必要になります。

```
POST /slack/command
```

https://github.com/Yarimizu14/slack-app-example/blob/master/app/controllers/slack/commands_controller.rb#L6-L26

- [Slack側から投げられるParameter](https://api.slack.com/interactivity/slash-commands#app_command_handling)に、`user_id`・`team_id`が含まれるため、OAuthの認証フローで紐付けたUser、Organizationを元に認可範囲を絞ります。
- ユーザーが入力したコマンドをパースしサブコマンドのような形で処理を分岐します。
- Slack連携の設定をDBに書き込みまたは削除します
- `response_url`にPOSTし、Slash Commandに対する返答を送ります


##### References

- https://github.com/integrations/slack
