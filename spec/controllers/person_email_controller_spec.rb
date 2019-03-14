require 'rails_helper'

RSpec.describe PersonEmailController, type: :controller do
  let(:valid_attributes) { attributes_for(:person) }
  let(:invalid_attributes) { { surname: '' } }
  let(:new_email) { 'my-new-email@digital.justice.gov.uk' }
  let(:oauth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'ditsso_internal',
      info: {
        email: new_email,
        first_name: 'John',
        last_name: 'Doe',
        name: 'John Doe'
      }
    )
  end

  describe 'GET edit' do
    let(:person) { create(:person, valid_attributes) }

    shared_examples 'renders edit template' do
      it { expect(response).to render_template :edit }

      it 'assigns the requested person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 'assigns new email as @new_email' do
        expect(assigns(:new_email)).to eq(new_email)
      end

      it 'assigns existing primary email as @new_secondary_email' do
        expect(assigns(:new_secondary_email)).to eq(person.email)
      end
    end

    context 'without authentication' do
      let(:request) { get :edit, params: { person_id: person.to_param } }

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    context 'with logged in user' do
      before do
        controller.singleton_class.class_eval do
          def current_user
            Person.first
          end
          helper_method :current_user
        end
      end

      let(:request) { get :edit, params: { person_id: person.to_param } }

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    context 'with oauth authentication' do
      before do
        get :edit, params: { person_id: person.to_param, oauth_hash: oauth_hash }
      end

      include_examples 'renders edit template'
    end
  end

  describe 'GET edit - when there is no internal_auth_key (edge case)' do
    let(:person) { create(:person) }

    before do
      person.update_attribute(:internal_auth_key, nil) # rubocop:disable Rails/SkipsModelValidations
      get :edit, params: { person_id: person.to_param, oauth_hash: oauth_hash }
    end

    it 'makes sure there is an internal_auth_key' do
      expect(assigns(:person).internal_auth_key).to eq(new_email)
    end

    it 'redirects to profile page' do
      expect(response).to redirect_to(person_path(person))
    end

    it 'sets a relevant flash message' do
      expect(flash[:notice]).to include('Your profile is now correctly setup')
    end
  end

  describe 'PUT update' do
    let(:person) { create(:person, given_name: "John", surname: "Doe", email: 'john.doe@digital.justice.gov.uk') }
    let(:new_attributes) { { email: 'john.doe2@digital.justice.gov.uk', secondary_email: 'john.doe@digital.justice.gov.uk', pager_number: '0100' } }

    context 'without authentication' do
      subject(:request) do
        put :update, params: { person_id: person.to_param, person: new_attributes }
      end

      it 'raises routing error for handling by server as Not Found' do
        expect { request }.to raise_error ActionController::RoutingError, 'Not Found'
      end
    end

    shared_examples 'updates the person' do
      it 'assigns person' do
        subject
        expect(assigns(:person)).to eql person
      end

      it 'updates email and secondary email only' do
        subject
        person.reload
        expect(person.email).to eql new_attributes[:email]
        expect(person.secondary_email).to eql new_attributes[:secondary_email]
        expect(person.pager_number).not_to eql new_attributes[:pager_number]
      end

      it 'redirects to profile page, ignoring desired path' do
        request.session[:desired_path] = new_group_path
        is_expected.to redirect_to person_path(person, prompt: 'profile')
      end

      it 'sets a flash message' do
        subject
        expect(flash[:notice]).to include("Your Primary work email has been updated to #{new_attributes[:email]}")
      end
    end

    context 'with oauth authentication' do
      subject { put :update, params: { person_id: person.to_param, person: new_attributes, oauth_hash: oauth_hash } }

      include_examples 'updates the person'
    end
  end
end
