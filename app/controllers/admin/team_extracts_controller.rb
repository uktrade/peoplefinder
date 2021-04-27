# frozen_string_literal: true

module Admin
  class TeamExtractsController < ApplicationController
    include ApplicationHelper

    require 'csv'
    before_action :authorize_user

    def show
      respond_to do |format|
        format.csv do
          send_data groups_csv, filename: "teams-#{Time.zone.today}.csv"
        end
      end
    end

    private

    def groups_csv
      @groups = Group.order(:id)

      CSV.generate(headers: true) do |csv|
        csv << team_headers
        @groups.each do |group|
          csv << group_row(group)
        end
      end
    end

    def team_headers
      %w[
        TeamId TeamName ParentId Ancestry
      ]
    end

    def group_row(group)
      [
        group.id,
        group.name,
        group.parent_id,
        group.ancestry
      ]
    end

    def authorize_user
      authorize 'Admin::Management'.to_sym, :csv_extract_report? # rubocop:disable Lint/SymbolConversion
    end
  end
end
