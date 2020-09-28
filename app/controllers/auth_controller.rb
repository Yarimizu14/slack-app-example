
class AuthController < ApplicationController

  # https://github.com/omniauth/omniauth#integrating-omniauth-into-your-application
  def callback
    @user = User.find_or_create_from_auth_hash(access_token['authed_user'])
    render plain: { message: 'ok', user_id: @user.id }.to_json
  end

  protected

  # example auth_hash
  # {
  #   "ok": true,
  #   "app_id": "A01BA1A3LRK",
  #   "authed_user": {
  #     "id": "UUUUUUUUU",
  #     "scope": "identity.basic",
  #     "access_token": "xoxp-11111111111-22222222222-3333333333333-44444444444444444444444444444444",
  #     "token_type": "user"
  #   },
  #   "scope": "commands,incoming-webhook",
  #   "token_type": "bot",
  #   "bot_user_id": "UUUUUUUUUUU",
  #   "team": {
  #     "id": "XXXXXXXXX",
  #     "name": "some-team-name"
  #   },
  #   "enterprise": null,
  #   "incoming_webhook": {
  #     "channel": "#general",
  #     "channel_id": "CCCCCCCCC",
  #     "configuration_url": "https://13nazca.slack.com/services/BBBBBBBBBBB",
  #     "url": "https://hooks.slack.com/services/TTTTTTTTT/BBBBBBBBBBB/xxxxxxxxxxxxxxxxxxxxxxxx"
  #   },
  #   "access_token": "xoxb-11111111111-2222222222222-333333333333333333333333",
  #   "refresh_token": null,
  #   "expires_at": null
  # }
  def access_token
    request.env['omniauth.strategy'].access_token.to_hash
  end
end