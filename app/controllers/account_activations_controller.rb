class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated? && user.authenticated?(:activation,
      params[:id])
      activation_user user
    else
      invalid_activation
    end
  end

  private

  def activation_user user
    user.activate
    log_in user
    flash[:success] = t "controllers.account_activations.m_success"
    redirect_to user
  end

  def invalid_activation
    flash[:danger] = t "controllers.account_activations.m_dan_active"
    redirect_to root_url
  end
end
