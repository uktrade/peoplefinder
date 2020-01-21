# frozen_string_literal: true

module Api::V2
  class PeopleController < Api::ApplicationController
    def show
      if person
        render json: PersonSerializer.new(person)
      else
        render nothing: true, status: :not_found
      end
    end

    private

    def person
      @person ||= Person.includes(:memberships, memberships: [:group]).find_by(ditsso_user_id: params.require(:id))
    end
  end
end
