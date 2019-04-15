require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  it_behaves_like 'session_person_creatable'

  let!(:person) { create(:person, given_name: 'John', surname: 'Doe', email: 'john.doe@digital.justice.gov.uk', ditsso_user_id: 'deadbeef') }

  let(:john_doe_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'ditsso_internal',
      info: {
        email: 'john.doe@digital.justice.gov.uk',
        first_name: 'John',
        last_name: 'Doe',
        name: 'John Doe'
      },
      uid: 'deadbeef'
    )
  end

  let(:same_uid_as_john_doe_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'ditsso_internal',
      info: {
        email: 'john.doe@totally-different.com',
        first_name: 'Johnathan',
        last_name: 'Doe-Jones',
        name: 'Johnathan Doe-Jones'
      },
      uid: 'deadbeef'
    )
  end

  let(:fred_bloggs_omniauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'ditsso_internal',
      info: {
        email: 'fred.bloggs@digital.justice.gov.uk',
        first_name: 'Fred',
        last_name: 'Bloggs',
        name: 'Fred Bloggs'
      },
      uid: 'dec0de'
    )
  end

  describe 'POST create' do
    context 'with omniauth' do
      context 'when person already exists' do
        before do
          request.env["omniauth.auth"] = john_doe_omniauth_hash
        end

        it 'does not create a user' do
          expect { post :create }.to_not change Person, :count
        end

        it 'redirects to the person\'s profiles page' do
          post :create
          expect(response).to redirect_to person_path(person, prompt: 'profile')
        end
      end

      context 'when person already exists with same UID but different email' do
        before do
          request.env["omniauth.auth"] = same_uid_as_john_doe_omniauth_hash
        end

        it 'does not create a user' do
          expect { post :create }.to_not change Person, :count
        end

        it 'redirects to the person\'s profiles page' do
          post :create
          expect(response).to redirect_to person_path(person, prompt: 'profile')
        end
      end

      context 'when person does not exist' do
        before do
          request.env["omniauth.auth"] = fred_bloggs_omniauth_hash
        end

        it 'creates the new person' do
          expect { post :create }.to change Person, :count
        end

        it 'creates person from oauth hash' do
          Timecop.freeze(Date.today - 1) { post :create }
          person = Person.first
          expect(person.email).to eql fred_bloggs_omniauth_hash['info']['email']
          expect(person.given_name).to eql fred_bloggs_omniauth_hash['info']['first_name']
          expect(person.surname).to eql fred_bloggs_omniauth_hash['info']['last_name']
          expect(person.ditsso_user_id).to eql fred_bloggs_omniauth_hash['uid']
        end

        it 'redirects to the person\'s profile edit page, ignoring desired path' do
          request.session[:desired_path] = new_group_path
          post :create
          expect(response).to redirect_to edit_person_path(Person.find_by(ditsso_user_id: 'dec0de'), page_title: "Create profile")
        end
      end
    end
  end

  describe 'POST create_person' do
    let(:person_params) do
      {
        person: {
          email: 'fred.bloggs@digital.justice.gov.uk',
          given_name: 'Fred',
          surname: 'Bloggs'
        }
      }
    end

    it 'creates the new person' do
      expect { post :create_person, params: person_params }.to change Person, :count
    end

    it 'redirects to the person\'s profile edit page, ignoring desired path' do
      request.session[:desired_path] = '/search'
      post :create_person, params: person_params
      expect(response).to redirect_to edit_person_path(Person.find_by(email: 'fred.bloggs@digital.justice.gov.uk'), page_title: "Create profile")
    end
  end
end
