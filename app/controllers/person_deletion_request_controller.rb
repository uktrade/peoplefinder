# frozen_string_literal: true

class PersonDeletionRequestController < ApplicationController
  def new
    breadcrumb :person_deletion_request, new_person_deletion_request_path(person)

    render 'new', locals: { person: person }
  end

  def create
    Zendesk.new.request_deletion(
      reporter: current_user,
      person_to_delete: person,
      note: params[:note]
    )

    notice(:request_sent)
    redirect_to person_path(person)
  end

  private

  def person
    @person ||= Person.friendly.find(params[:person_id])
  end
end
