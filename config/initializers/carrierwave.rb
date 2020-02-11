# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.configuration.x.s3.access_key.present?
    config.fog_provider = 'fog-aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.configuration.x.s3.access_key,
      aws_secret_access_key: Rails.configuration.x.s3.secret,
      region: Rails.configuration.x.s3.region
    }
    config.storage = :fog
    config.fog_directory = Rails.configuration.x.s3.bucket_name
    config.fog_public = false
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :file
  end
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end

  module DirHelpers
    def base_upload_dir
      Rails.env.test? ? "#{Rails.root}/spec/support/" : ''
    end
  end
end

if Rails.env.test?
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?

    klass.class_eval do
      def base_upload_dir
        "#{Rails.root}/spec/support/"
      end
    end
  end
end
