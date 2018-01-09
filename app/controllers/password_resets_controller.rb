class PasswordResetsController < ApplicationController
  before_action :find_user, :check_expiration, :valid_user,
    only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase

    if @user
      send_email_reset
      redirect_to root_url
    else
      flash.now[:danger] = t "controllers.password_reset.email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      add_errors
    elsif @user.update_attributes user_params
      log_in @user
      flash[:success] = t "controllers.password_reset.success"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def send_email_reset
    @user.create_reset_digest
    @user.send_code_email :password_reset
    flash[:info] = t "controllers.password_reset.sented_email"
  end

  def add_errors
    @user.errors.add :password, t("controllers.password_reset.do_not_blank")
    render :edit
  end

  def find_user
    @user = User.find_by email: params[:email]

    return if @user
    flash[:danger] = t "controllers.password_reset.user_not_found"
    redirect_to new_password_reset_url
  end

  def valid_user
    unless @user && @user.activated? &&
           @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def user_params
    params.require(:user).permit User::ATTRIBUTE_PARAMS_PASSWORD
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "controllers.password_reset.email_expired"
    redirect_to new_password_reset_url
  end
end
