# frozen_string_literal: true

require 'rails_helper'

describe 'Person maintenance' do
  let!(:department) { create(:department) }
  let(:person) { create(:person, :with_line_manager, email: 'test.user@digital.trade.gov.uk') }
  let(:another_person) { create(:person, email: 'someone.else@digital.trade.gov.uk') }

  before(:each, user: :regular) do
    omni_auth_log_in_as person.ditsso_user_id
  end

  before(:each, user: :people_editor) do
    omni_auth_log_in_as_people_editor
  end

  context 'Editing a person' do
    context 'for a regular user', user: :regular do
      it 'Editing a person', js: true do
        visit person_path(create(:person, person_attributes))
        click_edit_profile

        expect(page).to have_title("Edit profile - #{app_title}")
        fill_in 'First name', with: 'Jane'
        fill_in 'Last name', with: 'Doe'
        click_button 'Change team'
        within('.ws-team-browser') do
          choose department.name
        end
        click_button 'Save profile', match: :first

        expect(page).to have_content('We have let Jane Doe know that you’ve made changes')
        within('h1') do
          expect(page).to have_text('Jane Doe')
        end
      end

      it 'Validates required fields on person' do
        visit person_path(another_person)
        click_edit_profile
        fill_in 'First name', with: ''
        fill_in 'Last name', with: ''
        fill_in 'Main work email address', with: ''
        click_button 'Save', match: :first

        within('.govuk-error-summary') do
          expect(page).to have_text('Enter a first name')
          expect(page).to have_text('Enter a last name')
          expect(page).to have_text('Enter a main work email address')
        end
      end

      it 'Validates existence of at least one team membership', js: true do
        visit person_path(another_person)
        expect(another_person.memberships.count).to be 1
        click_edit_profile

        expect(page).to have_selector('.ws-profile-edit__team', count: 1)
        click_button 'Leave this team'
        expect(page).to have_selector('.ws-profile-edit__team', count: 0)

        click_button 'Save', match: :first

        within('.govuk-error-summary') do
          expect(page).to have_text('You must add at least one team and role')
        end
        expect(another_person.reload.memberships.count).to be 1
      end

      it 'Validates uniqueness of leader in department', js: true do
        role = 'Boss'
        create(:person, :member_of, team: department, role: role, leader: true)

        visit person_path(person)
        click_edit_profile

        expect(page).to have_selector('.ws-profile-edit__team', count: 1)

        check 'I am the head of this team', allow_label_click: true

        click_button 'Save', match: :first

        within('.govuk-error-summary') do
          expect(page).to have_text("#{department} can only have one leader, and there already is one")
        end
      end

      it 'Recording audit details' do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:remote_ip).and_return('1.2.3.4')
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:user_agent).and_return('NCSA Mosaic/3.0 (Windows 95)')

        with_versioning do
          person = create(:person, person_attributes)
          visit edit_person_path(person)

          fill_in 'First name', with: 'Jane'
          click_button 'Save', match: :first
        end

        version = Version.last
        expect(version.ip_address).to eq('1.2.3.4')
        expect(version.user_agent).to eq('NCSA Mosaic/3.0 (Windows 95)')
        expect(version.whodunnit).to eq(person)
      end

      it 'Cancelling an edit' do
        person = create(:person)
        visit edit_person_path(person)
        expect(page).to have_link('Cancel', href: person_path(person))
      end
    end
  end

  context 'Deleting a person' do
    context 'for a people editor', user: :people_editor do
      it 'Deleting a person' do
        person = create :person

        visit person_path(person)
        click_delete_profile
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'Allow deletion of a person even when there are memberships' do
        membership = create(:membership)
        person = membership.person
        visit person_path(person)
        click_delete_profile
        expect { Membership.find(membership.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context 'Viewing my own profile', user: :regular do
    it 'when it is incomplete' do
      visit person_path(person)
      expect(page).to have_text(/Your profile is only \d\d% complete/)
    end
  end

  context 'Viewing another person\'s profile' do
    context 'for a regular user', user: :regular do
      it 'when it is not complete' do
        visit person_path(another_person)
        expect(page).to have_text(/This profile is only \d\d% complete/)
      end
    end
  end
end
