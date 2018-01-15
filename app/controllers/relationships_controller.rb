class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]
    return unless @user
    follow @user
  end

  def destroy
    relationship = Relationship.find_by(id: params[:id])
    return unless relationship
    @user = relationship.followed
    unfollow @user
  end

  private

  def follow user
    current_user.follow user
    @relationship = current_user.active_relationships.find_by(followed_id: user.id)
    ajax_relationship user
  end

  def unfollow user
    current_user.unfollow user
    @relationship = current_user.active_relationships.build
    ajax_relationship user
  end

  def ajax_relationship user
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end
end
