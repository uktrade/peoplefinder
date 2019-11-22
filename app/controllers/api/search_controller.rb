# frozen_string_literal: true

module Api
  class SearchController < Api::ApplicationController
    include SearchHelper

    def index
      @teams = GroupSearch.new(query, SearchResults.new).perform_search
      @people = PersonSearch.new(query, SearchResults.new).perform_search

      render json: { teams: @teams.set, people: @people.set }
    end

    private

    def query
      params[:query]
    end
  end
end
