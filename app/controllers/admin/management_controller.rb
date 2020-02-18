# frozen_string_literal: true

require 'sidekiq/api'

module Admin
  class ManagementController < ApplicationController
    before_action :authorize_user

    # TODO: Remove once all controllers use new layout
    layout 'application'

    def show
      @sidekiq_stats = Sidekiq::Stats.new
    end

    private

    def authorize_user
      authorize 'Admin::Management'.to_sym, "#{action_name}?".to_sym
    end
  end
end
