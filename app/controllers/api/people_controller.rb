module Api
  class PeopleController < Api::ApplicationController
    before_action :set_person, only: [:show]

    def show
      if @person
        render json: @person
      else
        render json: { error: 'That person was not found' }, status: :not_found
      end
    end

    private

    def set_person
      @person = Person.find_by(ditsso_user_id: params[:ditsso_user_id]) if params[:ditsso_user_id].present?
    end
  end
end
