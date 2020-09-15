# frozen_string_literal: true

module Admin
  class ManagementPolicy < ApplicationPolicy
    # Headless policy - no model/ruby-class
    # override application policy to hardcode controller prefix as record
    def initialize(user, _record)
      super(user, :management)
    end

    def show?
      administrator?
    end

    def csv_extract_report?
      administrator?
    end

    def sidekiq?
      administrator?
    end

    def hr_data_imports?
      administrator?
    end
  end
end
