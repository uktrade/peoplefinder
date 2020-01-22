# frozen_string_literal: true

module Api
  class PeopleController < Api::ApplicationController
    def show
      if person
        render json: LegacyProfileSerializer.new(person)
      else
        render json: { error: 'That person was not found' }, status: :not_found
      end
    end

    private

    def person
      @person ||= Person.includes(:memberships).find_by(ditsso_user_id: params.require(:ditsso_user_id))
    end
  end
end
