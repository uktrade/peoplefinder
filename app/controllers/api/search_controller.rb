# frozen_string_literal: true

module Api
  class SearchController < Api::ApplicationController
    # TODO: This is a proof of concept!
    #   Unfortunately the existing search and API code doesn't give us much to work with. As
    #   this is just an experiment, rather than embarking on a huge refactor, it's just done in
    #   a quick and hacky way to let us surface search results including highlighting -
    #   if we end up productionising this, it should use serialisers (and be tested, obviously).
    #   And we should probably fix the search.

    include SearchHelper
    include ElasticsearchHelper

    def people
      @people = PersonSearch.new(query, SearchResults.new).perform_search.each_with_hit.map do |person, hit|
        {
          name: hit.highlight.name.try(:first) || hit.name,
          role_and_group: hit.highlight.role_and_group.try(:first) || hit.role_and_group,
          email: hit.highlight.email.try(:first) || hit.email,
          phone: person.phone,
          key_skills: hit.highlight.formatted_key_skills.try(:first) || hit.formatted_key_skills,
          profile_url: person_url(person),
          image_url: person.profile_image.try(:small).try(:url)
        }
      end

      render json: @people
    end

    def groups
      # TODO: Highlighting as GroupSearch doesn't use ElasticSearch.
      @groups = GroupSearch.new(query, SearchResults.new).perform_search.each.map do |group|
        {
          name: group.name,
          description: group.description,
          profile_url: group_url(group)
        }
      end

      render json: @groups
    end

    private

    def query
      params[:query]
    end
  end
end
