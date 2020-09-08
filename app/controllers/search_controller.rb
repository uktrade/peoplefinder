# frozen_string_literal: true

class SearchController < ApplicationController
  def show
    breadcrumb :search_results, :search

    @query = search_params[:query]

    render(
      'show',
      locals: { search: search }
    )
  end

  def people
    # TODO: This was originally implemented for an urgent requirement and needs to be cleaned up
    people_data = search.people_results.map do |p|
      {
        id: p.id,
        name: p.name,
        role_and_group: p.role_and_group
      }
    end

    render json: people_data.to_json
  end

  private

  def search
    @search ||= Search.new(search_params)
  end

  def search_params
    # Allows us to remain backwards-compatible with previous parameters for search so other applications and
    # bookmarked URLs don't break (also allows us to `require` search below because it will always be set).
    legacy_params = { search: { query: params[:query], filters: params[:search_filters] } }

    params.reverse_merge(legacy_params).require(:search).permit(:query, { filters: [] })
  end
end
