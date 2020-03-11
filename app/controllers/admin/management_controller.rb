# frozen_string_literal: true

require 'sidekiq/api'

module Admin
  class ManagementController < ApplicationController
    before_action :authorize_user

    # TODO: Remove once all controllers use new layout
    layout 'application'

    breadcrumb 'admin.management', :admin_home

    def show
      @sidekiq_stats = Sidekiq::Stats.new

      @people_metrics = OpenStruct.new(
        total_count: Person.count,
        with_line_manager_count: Person.where.not(line_manager_id: nil).count,
        with_photo_count: Person.where.not(profile_photo_id: nil).count,
        with_primary_phone_count: Person.where.not(primary_phone_number: '').count
      )
    end

    private

    def authorize_user
      authorize 'Admin::Management'.to_sym, "#{action_name}?".to_sym
    end
  end
end
