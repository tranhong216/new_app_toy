class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: (params_session :email)
    if user && user.authenticate(params_session(:password))
      check_active_user user
    else
      flash[:danger] = t "controllers.session.m_unsuccess"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def check_active_user user
    if user.activated?
      log_in user
      check_remember user
      redirect_back_or user
    else
      do_not_activated
    end
  end

  def do_not_activated
    message = t "controllers.session.m_unactive"
    flash[:warning] = message
    redirect_to root_url
  end

  def check_remember user
    params_session(:remember_me) == "1" ? remember(user) : forget(user)
  end
end
