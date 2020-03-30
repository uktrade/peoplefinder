# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do
  describe 'POST create' do
    let(:oauth_hash) { double('Authentication hash from omniauth_oauth2 gem') }
    let(:person) { instance_double(Person, id: 1987) }
    let(:context) { double('PersonLogin context', person: person, redirect_to_edit: redirect_to_edit) }
    let(:redirect_to_edit) { false }

    before do
      request.env['omniauth.auth'] = oauth_hash
      allow(LoginPerson).to receive(:call).with(oauth_hash: oauth_hash).and_return(context)
    end

    it "redirects to the user's profile by default" do
      post :create
      expect(response).to redirect_to(person_path(person))
    end

    context 'when a desired path is in the session' do
      it 'redirects to the desired path' do
        post :create, session: { desired_path: '/anywhere/but/here' }
        expect(response).to redirect_to('/anywhere/but/here')
      end
    end

    context 'when the redirect_to_edit flag is set' do
      let(:redirect_to_edit) { true }

      it 'redirects to the profile edit page' do
        post :create
        expect(response).to redirect_to(edit_person_path(person, page_title: 'Create profile'))
      end
    end
  end
end
