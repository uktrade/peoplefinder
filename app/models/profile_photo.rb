# frozen_string_literal: true

class ProfilePhoto < ApplicationRecord
  has_one :person
  mount_uploader :image, ImageUploader

  attr_accessor :upload_dimensions, :crop_x, :crop_y, :crop_w, :crop_h

  validates :image, image_dimensions: { min_width: 500, min_height: 500, max_width: 8192, max_height: 8192 }

  def image_cache=(value)
    # Force ActiveRecord to consider `image` attribute dirty when a cached image exists
    #
    # This works around a CarrierWave bug where upon form resubmission (where CarrierWave stores an uploaded image in
    # its cache) ActiveRecord doesn't know that the image has changed and doesn't save the `ProfilePhoto` record.
    image_will_change!
    super
  end
end
