# frozen_string_literal: true

module Api::V2
  class DataWorkspaceExportsController < Api::ApplicationController
    PER_PAGE = 100

    def show
      people = Person.page(page).per(PER_PAGE)
      results = people.map { |person| DataWorkspacePersonSerializer.new(person) }
      next_page = api_v2_data_workspace_export_url(page: people.next_page) unless people.last_page?

      render json: { results: results, next: next_page }
    end

    private

    def page
      params[:page] || 1
    end
  end
end
