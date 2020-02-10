# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonDeletionRequestController, type: :controller do
  before do
    mock_logged_in_user
  end

  let(:person) { create(:person) }

  describe 'GET new' do
    it 'assigns the requested person as @person' do
      get :new, params: { person_id: person.to_param }
      expect(assigns(:person)).to eq(person)
    end
  end

  describe 'POST create' do
    let(:zendesk) { instance_double(Zendesk) }

    before do
      allow(Zendesk).to receive(:new).and_return(zendesk)
    end

    it 'makes a Zendesk request and redirects' do
      expect(zendesk).to receive(:request_deletion).with(
        reporter: current_user,
        person_to_delete: person,
        note: 'This is a note'
      )

      post :create, params: { person_id: person.to_param, note: 'This is a note' }

      expect(response).to redirect_to(person_path(person))
    end
  end
end
