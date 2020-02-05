# frozen_string_literal: true

module Admin
  class ManagementController < ApplicationController
    before_action :authorize_user

    def show; end

    private

    def authorize_user
      authorize 'Admin::Management'.to_sym, "#{action_name}?".to_sym
    end
  end
end
