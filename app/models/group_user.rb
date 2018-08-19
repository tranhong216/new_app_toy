class GroupUser < ApplicationRecord
  belongs_to :user
  belongs_to :social_group

  before_destroy :delete_post

  private

  def delete_post
    ActiveRecord::Base.transaction do
      Micropost.post_by_group_user(social_group, user).each(&:destroy!)
      
    end
  end
end
