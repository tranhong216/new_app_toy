class User < ApplicationRecord
  enum sex: %i(male female maybe)
  ATTRIBUTE_PARAMS = %i(name email password password_confirmation
                        sex date_of_birth).freeze
  ATTRIBUTE_PARAMS_PASSWORD = %i(password password_confirmation).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_many :microposts, dependent: :destroy

  before_create :create_activation_digest
  before_save :email_downcase

  attr_reader :remember_token
  attr_accessor :activation_token, :reset_token

  validates :name, presence: true,
    length: {maximum: Settings.user_model.name_maximun}
  validates :email, presence: true,
    length: {maximum: Settings.user_model.email_maximun},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true,
    length: {minimum: Settings.user_model.password_minximun}, allow_nil: true
  validates :sex, inclusion: {in: :sex}, allow_nil: true
  validates :date_of_birth, presence: true
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

  private

  def email_downcase
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
