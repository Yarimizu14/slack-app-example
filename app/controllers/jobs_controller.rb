class JobsController < ApplicationController
  before_action :get_project
  before_action :set_job, only: [:show, :update, :destroy]

  # GET /jobs
  def index
    @jobs = @project.jobs

    render json: @jobs
  end

  # GET /jobs/1
  def show
    render json: @job
  end

  # POST /jobs
  def create
    @job = @project.jobs.build(job_params)

    if @job.save
      slack = OmniAuth::Slack.build_access_token(ENV['SLACK_OAUTH_CLIENT_ID'], ENV['SLACK_OAUTH_CLIENT_SECRET'], @project.organization.slack_bot_token)
      @project.slack_job_notifications.each do |n|
        slack.post('api/chat.postMessage', params: {channel: n.slack_channel_id, text: "Job #{@job.id} successfully finished"})
      end
      render json: @job, status: :created
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/1
  def update
    if @job.update(job_params)
      render json: @job
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
  end

  private
    def get_project
      @project = Project.find(params[:project_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = @project.jobs.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def job_params
      params.require(:job).permit(:description, :project_id)
    end
end
