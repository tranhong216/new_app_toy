class User < ApplicationRecord

  enum sex: %i(male female maybe)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save :email_downcase

  validates :name, presence: true,
    length: {maximum: Settings.user_model.name_maximun}
  validates :email, presence: true,
    length: {maximum: Settings.user_model.email_maximun},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true,
    length: {minimum: Settings.user_model.password_minximun}
  validates :sex, inclusion: {in: :sex}

  has_secure_password

  private

  def email_downcase
    email.downcase!
  end
end
