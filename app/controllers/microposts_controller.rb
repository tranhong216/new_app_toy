class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :find_social_group, only: :create
  before_action :correct_user, only: :destroy

  def create
    @micropost = (social_group || current_user).microposts.build micropost_params
    if micropost.save
      flash[:success] = t "controllers.micropost.post_create"
      redirect_to request.referer || root_url
    else
      create_fail
    end
  end

  def destroy
    micropost.destroy
    flash[:success] = t "controllers.micropost.post_delete"
    redirect_to request.referer || root_url
  end

  private

  attr_reader :social_group, :micropost

  def micropost_params
    params.require(:micropost).permit Micropost::ATTRIBUTE_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if micropost
    redirect_to root_url
  end

  def find_social_group
    @social_group = SocialGroup.find_by id: params[:social_group_id]
  end

  def create_fail
    if social_group
      create_group_post_fail
    else
      @feed_items = current_user.feed.paginate page: params[:page]
      render "static_pages/home"
    end
  end

  def create_group_post_fail
    group_user = current_user.group_users.find_by social_group: social_group

    return redirect_to social_groups_path unless group_user
    @support_group = Supports::SocialGroupSupport
      .new social_group: social_group, group_user: group_user,
        micropost: micropost
    render "social_groups/show"
  end
end
