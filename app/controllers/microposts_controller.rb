class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t "controllers.micropost.post_create"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate page: params[:page]
      render "static_pages/home"
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t "controllers.micropost.post_delete"
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit Micropost::ATTRIBUTE_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return unless @micropost
    redirect_to root_url
  end
end
