class SuggestionsController < ApplicationController

  def new
    @person = Person.friendly.find(params[:person_id])
    authorize @person
    @suggestion = Suggestion.new
  end

  def create
    @suggestion = Suggestion.new(suggestion_params)
    if @suggestion.valid?
      person = Person.friendly.find(params[:person_id])
      authorize person
      @delivery_details =
        SuggestionDelivery.deliver(person, current_user, @suggestion)
      render :create
    else
      render :new
    end
  end

  private

  def suggestion_params
    # TODO: #to_h is required due to issues with legacy `virtus` gem that lacks Rails 5
    #       and ActionController::Parameters support.
    params.require(:suggestion).permit!.to_h
  end
end
