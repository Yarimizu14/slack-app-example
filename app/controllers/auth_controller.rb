
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
    unless @user.update(slack_id: slack_user['id'])
      render json: @user.errors, status: :unprocessable_entity
    end

    slack_team = access_token['team']
    bot_token = access_token[:access_token]
    unless @user.organization.update(slack_team_id: slack_team['id'], slack_bot_token: bot_token)
      render json: @user.organization.errors, status: :unprocessable_entity
    end

    render plain: { message: 'ok', user_id: @user.id }.to_json
  end

  protected


  # example auth_hash
  # {
  #   "ok": true,
  #   "app_id": "AAAAAAAAAAA",
  #   "authed_user": {
  #     "id": "UUUUUUUUU"
  #   },
  #   "scope": "commands,chat:write,chat:write.customize,links:read,links:write,team:read",
  #   "token_type": "bot",
  #   "bot_user_id": "UUUUUUUUUUU",
  #   "team": {
  #     "id": "TTTTTTTTT",
  #     "name": "xxxxx"
  #   },
  #   "enterprise": null,
  #   "access_token": "xoxb-11111111111-2222222222222-333333333333333333333333",
  #   "refresh_token": null,
  #   "expires_at": null
  # }
  def access_token
    request.env['omniauth.strategy'].access_token.to_hash
  end
end