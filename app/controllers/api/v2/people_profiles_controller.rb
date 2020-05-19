# frozen_string_literal: true

module Api::V2
  class PeopleProfilesController < Api::V2::ApplicationController
    def show
      if person
        render json: PersonProfileSerializer.new(person)
      else
        head :not_found, content_type: 'application/json'
      end
    end

    private

    def person
      @person ||= Person.find_by(ditsso_user_id: params.require(:ditsso_user_id))
    end

    def client_public_key
      Rails.configuration.api_people_profiles_public_key
    end
  end
end
