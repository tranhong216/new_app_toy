class Micropost < ApplicationRecord
  ATTRIBUTE_PARAMS = %i(content picture).freeze

  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum:
    Settings.micropost_model.content_maximun}
  validate  :picture_size

  scope :order_time, ->{order created_at: :desc}
  mount_uploader :picture, PictureUploader

  private

  def picture_size
    return unless picture.size > Settings.micropost_model.picture_maximun.megabytes
    errors.add :picture, t("model.micropost.picture_size")
  end
end
