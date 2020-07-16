# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeopleController, type: :controller do
  before do |example|
    mock_logged_in_user unless example.metadata[:user] == :administrator
  end

  before(:each, user: :administrator) do
    mock_logged_in_user administrator: true
  end

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:person).merge(default_membership_attributes)
  end

  let(:default_membership_attributes) do
    { memberships_attributes: [attributes_for(:membership_default)] }
  end

  let(:invalid_attributes) do
    { surname: '' }
  end

  describe 'GET show' do
    it 'assigns the requested person as @person' do
      person = create(:person, valid_attributes)
      get :show, params: { id: person.to_param }
      expect(assigns(:person)).to eq(person)
    end
  end

  describe 'GET edit' do
    let(:person) { create(:person, valid_attributes) }

    it 'assigns the requested person as @person' do
      get :edit, params: { id: person.to_param }
      expect(assigns(:person)).to eq(person)
    end

    context 'building memberships' do
      it 'builds a membership if there isn\'t one already' do
        person.memberships.destroy_all
        expect(person.memberships.count).to eq 0
        get :edit, params: { id: person.to_param }
        expect(assigns(:person).memberships.length).to be(1)
      end

      it 'does not build a membership when there is one already' do
        expect(person.memberships.count).to eq 1
        get :edit, params: { id: person.to_param }
        expect(assigns(:person).memberships.length).to be(1)
      end
    end
  end

  describe 'PUT update myself' do
    let(:person) { current_user }

    before do
      put :update, params: { id: person.to_param, person: new_attributes, commit: 'Save' }
    end

    describe 'with valid params' do
      let(:new_attributes) do
        attributes_for(:person).merge(works_tuesday: false)
      end

      it 'updates the person apart from SSO ID' do
        person.reload
        new_attributes.each do |key, value|
          next if key == :ditsso_user_id

          expect(person.__send__(key)).to eql value
        end
      end

      it 'shows no notice about informing the person' do
        expect(flash[:notice]).not_to match(/We have let/)
        expect(flash[:notice]).to match(/Updated your profile/)
      end
    end

    describe 'when trying to grant administrator role' do
      let(:new_attributes) do
        attributes_for(:person).merge(role_administrator: true)
      end

      it 'does not grant the role' do
        person.reload
        expect(person).not_to be_role_administrator
      end
    end
  end

  describe 'PUT update a third party' do
    let(:person) { create(:person, valid_attributes) }

    describe 'with valid params' do
      let(:new_attributes) do
        attributes_for(:person).merge(
          works_monday: true,
          works_tuesday: false,
          works_saturday: true,
          works_sunday: false
        )
      end

      before do
        put :update, params: { id: person.to_param, person: new_attributes, commit: 'Save' }
      end

      it 'updates the requested person apart from SSO ID' do
        person.reload
        new_attributes.each do |attr, value|
          expect(person.send(attr)).to eql(value) if attr != :ditsso_user_id
        end
      end

      it 'allows update of e-mail too' do
        person.reload
        expect(person.email).to eql(new_attributes[:email])
      end

      it 'assigns the requested person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 'redirects to the person' do
        expect(response).to redirect_to(person)
      end

      it 'shows a notice about informing the person' do
        expect(flash[:notice]).to match(/We have let/)
      end
    end

    describe 'with invalid params' do
      before do
        put :update, params: { id: person.to_param, person: invalid_attributes }
      end

      it 'assigns the person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 're-renders the edit template' do
        expect(response).to render_template('edit')
      end
    end

    describe 'when trying to change super-admin only parameters' do
      let(:attributes_with_role_administrator) do
        attributes_for(:administrator).merge(ditsso_user_id: 'new_id')
      end

      before do
        put :update, params: { id: person.to_param, person: attributes_with_role_administrator }
      end

      context 'if the current user is not an administrator themselves' do
        it 'does not grant the role or update the SSO user id' do
          person.reload
          expect(person).not_to be_role_administrator
          expect(person.ditsso_user_id).not_to eq('new_id')
        end
      end

      context 'if the current user IS a super user', user: :administrator do
        it 'grants administrator role' do
          person.reload
          expect(person).to be_role_administrator
          expect(person.ditsso_user_id).to eq('new_id')
        end
      end
    end
  end

  describe 'DELETE destroy', user: :administrator do
    before do
      allow(RemovePerson).to receive(:call).with(person: person).and_return(context)
      delete :destroy, params: { id: person.to_param }
    end

    context 'when the interactor is successful' do
      let(:context) { double(success?: true) }

      context 'when the person was a member of a group' do
        let(:person) { create(:person) }

        it 'redirects to the first group' do
          expect(response).to redirect_to(group_path(person.groups.first))
        end
      end

      context 'when the person was not a member of any groups' do
        let(:person) { create(:person) { |p| p.memberships.delete_all } }

        it 'redirects to the homepage' do
          expect(response).to redirect_to(home_path)
        end
      end
    end

    context 'when the interactor fails' do
      let(:context) { double(success?: false) }
      let(:person) { create(:person) }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(home_path)
      end
    end
  end
end
