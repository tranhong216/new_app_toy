class Profile < ApplicationRecord
  enum sex: %i(male female maybe)
  ATTRIBUTE_PARAMS = %i(name sex date_of_birth).freeze

  belongs_to :user

  validates :name, presence: true,
    length: {maximum: Settings.user_model.name_maximun}
  validates :sex, inclusion: {in: :sex}, allow_nil: true
  validates :date_of_birth, presence: true
end
