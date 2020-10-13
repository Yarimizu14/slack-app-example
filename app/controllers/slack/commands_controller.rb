class Slack::CommandsController < ApplicationController
  before_action :get_user

  def create
    if @user.organization.slack_team_id != params[:team_id]
      render json: {err: 'invalid_team_id'}, status: :unprocessable_entity
    else
      render plain: { message: 'ok', user_id: @user.id }.to_json
    end
  end

  private
    def get_user
      @user = User.find_by(slack_id: params[:user_id])
    end

    # https://api.slack.com/interactivity/slash-commands#app_command_handling
    def command_params
      params.permit(:response_url, :team_id, :user_id, :text)
    end
end
