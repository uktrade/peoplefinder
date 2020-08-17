# frozen_string_literal: true

require 'fastimage'

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::DirHelpers

  # Storage location is configured per-environment in
  # config/initializers/carrierwave.rb

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    format(
      '%suploads/peoplefinder/%s/%s/%s',
      base_upload_dir,
      model.class.to_s.underscore,
      mounted_as,
      model.id
    )
  end

  def default_url
    [version_name, 'no_photo.png'].compact.join('_')
  end

  process :auto_orient # this should go before all other "process" steps

  def auto_orient
    manipulate! do |image|
      image.tap(&:auto_orient)
    end
  end

  version :croppable do
    before :cache, :store_upload_dimensions
  end

  version :medium, from_version: :croppable do
    process :crop
    process resize_to_limit: [512, 512]
    process quality: 60
  end

  version :small, from_version: :croppable do
    process :crop
    process resize_to_limit: [150, 150]
    process quality: 60
  end

  def crop
    return if model.crop_x.blank?

    manipulate! do |img|
      img.crop "#{model.crop_w}x#{model.crop_h}+#{model.crop_x}+#{model.crop_y}"
      img
    end
  end

  private

  def content_type_whitelist
    %w[image/jpg image/jpeg image/png]
  end

  def size_range
    1..8.megabytes
  end

  def uploaded_file_dimensions
    w, h = FastImage.size(file.file)
    { width: w, height: h }
  end

  def store_upload_dimensions(_file)
    model.upload_dimensions = uploaded_file_dimensions if model.upload_dimensions.nil?
  end
end
