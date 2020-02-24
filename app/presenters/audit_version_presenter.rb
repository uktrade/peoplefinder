# frozen_string_literal: true

require 'forwardable'
require 'yaml'

class AuditVersionPresenter
  extend Forwardable
  def_delegators :@version, :event, :whodunnit, :created_at

  def initialize(version)
    @version = version
  end

  def changes
    YAML.load(@version.object_changes).map do |field, (_, new)|
      value = new.presence || '(deleted)'
      [field, value]
    end
  end

  def self.wrap(versions)
    Array(versions).map do |version|
      AuditVersionPresenter.new(version)
    end
  end
end
