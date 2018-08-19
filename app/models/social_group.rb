class SocialGroup < ApplicationRecord
  ATTRIBUTE_PARAMS = %i(name).freeze

  has_many :group_users, dependent: :destroy
  has_many :microposts, dependent: :destroy
  has_many :members, through: :group_users, source: :user

  after_save :admin_join_group

  def member? user
    members.include? user
  end

  def feed
    microposts.order_time
  end

  private

  def admin_join_group
    ActiveRecord::Base.transaction do
      User.admins.each do |admin|
        group_users.create! user: admin
      end
    end
  end
end
