# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  before_action :set_search_args

  def index
    @team_results = search(GroupSearch) if teams_filter?
    @people_results = search(PersonSearch) if people_filter?
  end

  def people
    # TODO: This was implemented for an urgent requirement and needs to be cleaned up
    people = search(PersonSearch).set.records

    people_data = people.map do |p|
      {
        id: p.id,
        name: p.name,
        role_and_group: p.role_and_group
      }
    end

    render json: people_data.to_json
  end

  private

  def search(klass)
    search = klass.new(@query, SearchResults.new)
    search.perform_search
  end

  def query
    params[:query]
  end

  def set_search_args
    @query = query
    @search_filters = (params[:search_filters] || [])
  end
end
