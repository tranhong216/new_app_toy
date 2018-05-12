class User < ApplicationRecord
  ATTRIBUTE_PARAMS = [:email, :password, :password_confirmation,
                      profile_attributes: Profile::ATTRIBUTE_PARAMS].freeze
  ATTRIBUTE_PARAMS_PASSWORD = %i(password password_confirmation).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_one :profile, dependent: :destroy
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :group_users, dependent: :destroy

  delegate :name, to: :profile

  scope :admins, ->{where admin: true}

  accepts_nested_attributes_for :profile, update_only: true

  before_create :create_activation_digest
  before_save :email_downcase

  attr_reader :remember_token
  attr_accessor :activation_token, :reset_token

  validates :email, presence: true,
    length: {maximum: Settings.user_model.email_maximun},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true,
    length: {minimum: Settings.user_model.password_minximun}, allow_nil: true

  has_secure_password

  class << self
    def digest string
      cost =
        if ActiveModel::SecurePassword.min_cost
          BCrypt::Engine::MIN_COST
        else
          BCrypt::Engine.cost
        end
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    @remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.blank?
    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attributes remember_digest: nil
  end

  def current_user? current_user
    self == current_user
  end

  def activate
    update_attributes activated: true, activated_at: Time.zone.now
  end

  def send_code_email attribute
    UserMailer.send(attribute.to_s, self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
  end

  def password_reset_expired?
    reset_sent_at < Settings.user_model.time_expired.hours.ago
  end

  def feed
    microposts.order_time
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  private

  def email_downcase
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
