# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.has_value_object(value_object, constructor: nil, class_name: nil) # rubocop:disable Naming/PredicateName
    composed_of value_object,
                allow_nil: true,
                mapping: [[value_object.to_s, 'value']],
                constructor: constructor,
                class_name: class_name
  end
end
