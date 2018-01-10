class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :find_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def show
    @microposts = @user.microposts.order_time.paginate page: params[:page]
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_code_email :account_activation
      flash[:info] = t "controllers.user.email_active"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "controllers.user.updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "controllers.user.deleted"
    else
      flash[:danger] = t "controllers.user.delele_fail"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit User::ATTRIBUTE_PARAMS
  end

  def correct_user
    redirect_to root_url unless @user.current_user? current_user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.find_by id: params[:id]

    return if @user
    flash[:danger] = t "controllers.user.not_found_user"
    redirect_to login_url
  end
end
