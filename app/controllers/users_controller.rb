class UsersController < ApplicationController
  before_action :get_organization
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = @organization.users.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = @organization.users.build(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    def get_organization
      # @organization = Organization.find(params[:organizations_id])
      @organization = Organization.find(params[:organization_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      # @user = User.find(params[:id])
      @user = @organization.users.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name)
      # params.fetch(:user, {})
    end
end
