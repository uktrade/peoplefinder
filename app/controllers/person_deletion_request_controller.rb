# frozen_string_literal: true

class PersonDeletionRequestController < ApplicationController
  before_action :set_person

  def new; end

  def create
    Zendesk.new.request_deletion(
      reporter: current_user,
      person_to_delete: @person,
      note: params[:note]
    )

    notice(:request_sent)
    redirect_to person_path(@person)
  end

  private

  def set_person
    @person = Person.friendly.find(params[:person_id])
  end
end
