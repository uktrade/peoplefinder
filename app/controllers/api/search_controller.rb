# frozen_string_literal: true

module Api
  class SearchController < Api::ApplicationController
    # TODO: This is a proof of concept!
    #   Unfortunately the existing search and API code doesn't give us much to work with. As
    #   this is just an experiment, rather than embarking on a huge refactor, it's just done in
    #   a quick and hacky way to let us surface search results including highlighting -
    #   if we end up productionising this, it should use serialisers (and be tested, obviously).
    #   And we should probably fix the search.

    include ApplicationHelper
    include PeopleHelper
    include SearchHelper
    include ElasticsearchHelper

    def people
      results = PersonSearch.new(query, SearchResults.new).perform_search

      if results.size.zero?
        # Avoid serializer rendering bogus JSON on empty result by forcing rendering of an empty array
        render json: [].to_json
      else
        @people = results.each_with_hit.map do |person, hit|
          {
            name: hit.try(:highlight).try(:name).try(:first) || hit.name,
            role_and_group: hit.try(:highlight).try(:role_and_group).try(:first) || hit.role_and_group,
            email: hit.try(:highlight).try(:email).try(:first) || hit.email,
            phone: phone_number_with_country_code(person.primary_phone_country, person.phone),
            key_skills: hit.try(:highlight).try(:formatted_key_skills).try(:first) || hit.formatted_key_skills,
            languages: hit.try(:highlight).try(:languages).try(:first) || hit.languages,
            profile_url: person_url(person),
            image_url: ActionController::Base.helpers.asset_url(profile_image_source(person, {}), type: :image)
          }
        end

        render json: @people
      end
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

      if @groups.size.zero?
        # Avoid serializer rendering bogus JSON on empty result by forcing rendering of an empty array
        render json: [].to_json
      else
        render json: @groups
      end
    end

    private

    def query
      params[:query]
    end
  end
end
