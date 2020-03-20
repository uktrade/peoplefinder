# frozen_string_literal: true

class ApplicationValueObject
  attr_reader :value

  delegate :to_s, to: :value

  def initialize(raw_value)
    raise ArgumentError, 'Raw value must be symbol or implicitly convertible' unless raw_value.respond_to?(:to_sym)

    @value = raw_value.to_sym
    freeze
  end

  def ==(other)
    other.is_a?(self.class) && other.value == value
  end
  alias === ==
  alias eql? ==

  def hash
    [ApplicationValueObject, self.class, value].hash
  end
end
