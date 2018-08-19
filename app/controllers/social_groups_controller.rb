class SocialGroupsController < ApplicationController
  before_action :find_social_group, :check_user_in_group, only: :show

  def index
    @social_groups = SocialGroup.all
  end

  def new
    @social_group = SocialGroup.new
  end

  def create
    @social_group = SocialGroup.new social_group_params
    if social_group.save
      flash[:success] = "Tạo group thành công"
      redirect_to social_groups_path
    else
      flash[:warning] = "Tạo group thất bại"
      render :new
    end
  end

  def show
    group_user = current_user.group_users.find_by social_group: social_group

    return redirect_to social_groups_path unless group_user
    @support_group = Supports::SocialGroupSupport
      .new social_group: social_group, group_user: group_user
  end

  private

  attr_reader :social_group, :group_user

  def social_group_params
    params.require(:social_group).permit SocialGroup::ATTRIBUTE_PARAMS
  end

  def find_social_group
    @social_group = SocialGroup.find_by id: params[:id]

    return if social_group
    flash[:warning] = "Không tìm thấy group"
    redirect_to social_groups_path
  end

  def check_user_in_group
    return if social_group.member?(current_user)

    flash[:warning] = "Bạn không phải thành viên của group"
    redirect_to social_groups_path
  end
end
