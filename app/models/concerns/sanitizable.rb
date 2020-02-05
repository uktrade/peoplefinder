# frozen_string_literal: true

module Sanitizable
  extend ActiveSupport::Concern

  included do
    class_attribute :fields_to_sanitize, instance_writer: false
    self.fields_to_sanitize = {}

    before_validation :sanitize!
  end

  def sanitize!
    fields_to_sanitize.each do |field, options|
      value = public_send(field)
      next unless value

      sanitized_value = sanitize_value(value, options)
      assign_attributes(field => sanitized_value)
    end
  end

  private

  def sanitize_value(value, options)
    value = value.strip if strip?(value, options)
    value = value.downcase if downcase?(value, options)
    value = value.gsub(/\d/, '') if remove_digits?(value, options)
    value
  end

  def strip?(value, options)
    value.respond_to?(:strip) && options[:strip]
  end

  def downcase?(value, options)
    value.respond_to?(:downcase) && options[:downcase]
  end

  def remove_digits?(value, options)
    value.respond_to?(:gsub) && options[:remove_digits]
  end

  module ClassMethods
    def sanitize_fields(*fields, **options)
      fields.each do |field|
        fields_to_sanitize[field] = options
      end
    end
  end
end
