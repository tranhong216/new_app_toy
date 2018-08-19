class GroupUsersController < ApplicationController
  before_action :find_group, only: :create
  before_action :find_group_user, only: :destroy

  def create
    group_user = social_group.group_users.build user: current_user

    if group_user.save
      flash[:success] = "Da vao group"
      redirect_to social_group_path(social_group)
    else
      flash[:warning] = "Khong tim the tham gia grop"
      redirect_to social_groups_path
    end
  end

  def destroy
    if group_user.destroy
      flash[:success] = "Roi nhom thanh cong"
    else
      flash[:danger] = "Roi nhom that bai"
    end
    redirect_to social_groups_path
  end

  private

  attr_reader :social_group, :group_user

  def find_group
    @social_group = SocialGroup.find_by id: params[:social_group_id]

    return if social_group
    flash[:warning] = "Khong tim thay group"
    redirect_to social_groups_path
  end

  def find_group_user
    @group_user = GroupUser.find_by id: params[:id]

    return if group_user
    flash[:warning] = "Ban khong nam trong group nay"
    redirect_to social_groups_path
  end
end
