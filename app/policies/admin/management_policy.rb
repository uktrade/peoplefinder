# frozen_string_literal: true

module Admin
  class ManagementPolicy < ApplicationPolicy
    # Headless policy - no model/ruby-class
    # override application policy to hardcode controller prefix as record
    def initialize(user, _record)
      super(user, :management)
    end

    def show?
      admin_user?
    end

    def csv_extract_report?
      admin_user?
    end
  end
end
