class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: (params_session :email)
    if user && user.authenticate(params_session(:password))
      success
    else
      unsuccess
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def success
    user = User.find_by email: params_session(:email)
    log_in user
    params_session(:remember_me) == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def unsuccess
    flash[:danger] = t "controllers.session.m_unsuccess"
    render :new
  end
end
