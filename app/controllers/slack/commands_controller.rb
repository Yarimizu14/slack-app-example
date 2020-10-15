require 'rest-client'

class Slack::CommandsController < ApplicationController
  before_action :get_user

  def create
    text = params[:text]
    t = text.strip.split(/\s+/)

    return render json: {err: 'invalid_team_id'}, status: :unprocessable_entity if @user.organization.slack_team_id != params[:team_id]
    return render json: {err: 'invalid_command'}, status: :unprocessable_entity if t.size == 0

    subcommand = t.shift
    case subcommand
    when 'subscribe' then
      subscribe t
    when 'unsubscribe' then
      unsubscribe t
    else
      return render json: {err: 'invalid_command'}, status: :unprocessable_entity
    end

    RestClient.post command_params[:response_url], {text: "`#{subcommand}` setting completed!"}.to_json, {content_type: :json, accept: :json}

    render plain: { message: 'ok', user_id: @user.id }.to_json
  end

  private
    def get_user
      @user = User.find_by(slack_id: params[:user_id])
    end

    # https://api.slack.com/interactivity/slash-commands#app_command_handling
    def command_params
      params.permit(:response_url, :team_id, :user_id, :text, :channel_id, :channel_name)
    end

    def subscribe(command_args)
      project_name = command_args.shift
      project = @user.organization.projects.find_by(name: project_name.to_s)

      setting = SlackJobNotification.new(
          slack_channel_id: command_params[:channel_id],
          slack_channel_name: command_params[:channel_name],
          project_id: project.id
      )
      setting.save!
    end

    def unsubscribe(command_args)
      project_name = command_args.shift
      project = @user.organization.projects.find_by(name: project_name.to_s)

      setting = project.slack_job_notifications.find_by(slack_channel_id: command_params[:channel_id])
      setting.delete
    end
end
