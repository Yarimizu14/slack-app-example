
class AuthController < ApplicationController

  def login
    session[:user_id] = params[:user_id]
    redirect_to "/auth/slack"
  end

  # https://github.com/omniauth/omniauth#integrating-omniauth-into-your-application
  def callback
    user_id = session[:user_id]
    @user = User.find(user_id)

    slack_user = access_token['authed_user']
    unless @user.update(slack_id: slack_user['id'], access_token: slack_user['access_token'])
      render json: @user.errors, status: :unprocessable_entity
    end

    slack_team = access_token['team']
    unless @user.organization.update(slack_team_id: slack_team['id'])
      render json: @user.organization.errors, status: :unprocessable_entity
    end

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