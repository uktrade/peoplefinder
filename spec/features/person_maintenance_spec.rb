# frozen_string_literal: true

require 'rails_helper'

describe 'Person maintenance' do
  include ActiveJobHelper

  let(:department) { create(:department) }
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:super_admin) { create(:super_admin, email: 'super.admin@digital.justice.gov.uk') }
  let(:another_person) { create(:person, email: 'someone.else@digital.justice.gov.uk') }

  before do
    department
  end

  before(:each, user: :regular) do
    omni_auth_log_in_as person.ditsso_user_id
  end

  before(:each, user: :super_admin) do
    omni_auth_log_in_as_super_admin
  end

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:profile_page) { Pages::Profile.new }

  let(:completion_prompt_text) do
    'Fill in the highlighted fields to achieve 100% profile completion'
  end

  context 'Editing a person' do
    context 'for a regular user', user: :regular do
      it 'Editing a person', js: true do
        visit person_path(create(:person, person_attributes))
        click_edit_profile

        expect(page).to have_title("Edit profile - #{app_title}")
        expect(page).not_to have_text(completion_prompt_text)
        fill_in 'First name', with: 'Jane'
        fill_in 'Last name', with: 'Doe'
        click_link 'Change team'
        select_in_team_select 'Ministry of Justice'
        click_button 'Save', match: :first

        expect(page).to have_content('We have let Jane Doe know that you’ve made changes')
        within('h1') do
          expect(page).to have_text('Jane Doe')
        end
      end

      it 'Editing my own profile from a normal edit link' do
        visit person_path(person)
        click_edit_profile
        expect(page).not_to have_text(completion_prompt_text)
      end

      it 'Editing my own profile from a "complete your profile" link' do
        visit person_path(person)
        click_link 'complete your profile', match: :first
        expect(page).to have_text(completion_prompt_text)
      end

      it 'Editing another person\'s profile from a "complete this profile" link' do
        visit person_path(another_person)
        click_link 'complete this profile', match: :first
        expect(page).to have_text(completion_prompt_text)
      end

      it 'Validates required fields on person' do
        visit person_path(another_person)
        click_edit_profile
        fill_in 'First name', with: ''
        fill_in 'Last name', with: ''
        fill_in 'Primary work email', with: ''
        click_button 'Save', match: :first

        expect(edit_profile_page).to have_error_summary
        expect(edit_profile_page.error_summary).to have_given_name_error
        expect(edit_profile_page.error_summary).to have_surname_error
        expect(edit_profile_page.error_summary).to have_email_error
      end

      it 'Validates required fields on team memberships', js: true do
        visit person_path(another_person)
        click_edit_profile
        click_link 'Join another team'
        expect(edit_profile_page).to have_selector('.membership.panel', count: 2)
        click_button 'Save', match: :first
        expect(edit_profile_page.error_summary).to have_team_required_error text: 'Team is required', count: 1
        expect(edit_profile_page.form).to have_team_required_field_errors text: 'Team is required', count: 1
      end

      it 'Validates existence of at least one team membership', js: true do
        visit person_path(another_person)
        expect(another_person.memberships.count).to be 1
        click_edit_profile
        expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 1)
        click_link 'Leave team'
        expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 0)
        click_button 'Save', match: :first
        expect(edit_profile_page.error_summary).to have_team_membership_required_error text: 'Membership of a team is required'
        expect(edit_profile_page.form).to have_team_membership_error_destination_anchor
        expect(another_person.reload.memberships.count).to be 1
      end

      it 'Validates uniqueness of leader in department', js: true do
        role = 'Boss'
        create(:person, :member_of, team: department, role: role, leader: true)

        visit person_path(person)
        click_edit_profile
        expect(edit_profile_page).to have_selector('.membership.panel', count: 1)
        within '.team-leader' do
          govuk_label_click 'Yes'
        end
        click_button 'Save', match: :first
        expect(edit_profile_page.error_summary).to have_leader_unique_error
        expect(edit_profile_page.error_summary.leader_unique_error).to have_text "#{role} (leader of #{department}) already exists. Select \"No\" or change the current #{role}'s profile first", count: 1
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

      it 'Editing an invalid person' do
        person = create(:person, person_attributes)

        edit_profile_page.load(slug: person.slug)

        edit_profile_page.form.surname.set ''
        edit_profile_page.form.save.click

        expect(edit_profile_page).to have_error_summary
        expect(edit_profile_page.error_summary).to have_surname_error
      end

      it 'Cancelling an edit' do
        person = create(:person)
        visit edit_person_path(person)
        expect(page).to have_link('Cancel', href: person_path(person))
      end
    end
  end

  context 'Deleting a person' do
    context 'for a super admin user', user: :super_admin do
      it 'Deleting a person' do
        person = create :person
        email_address = person.email
        given_name = person.given_name

        visit person_path(person)
        click_delete_profile
        expect { Person.find(person.id) }.to raise_error(ActiveRecord::RecordNotFound)

        expect(last_email.to).to include(email_address)
        expect(last_email.subject).to eq('Your profile on DIT People Finder has been deleted')
        expect(last_email.body.encoded).to match("Hello #{given_name}")
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
    it 'when it is complete' do
      complete_profile!(person)
      visit person_path(person)
      expect(page).to have_text('Profile completeness 100%')
      expect(page).to have_text('Thanks for improving People Finder for everyone!')
    end

    it 'when it is incomplete' do
      visit person_path(person)
      expect(page).to have_text('Profile completeness')
      expect(page).to have_text('complete your profile')
    end
  end

  context 'Viewing another person\'s profile' do
    context 'for a regular user', user: :regular do
      it 'when it is complete' do
        complete_profile!(another_person)
        visit person_path(another_person)
        expect(page).not_to have_text('Profile completeness')
      end

      it 'when it is not complete' do
        visit person_path(another_person)
        expect(page).to have_text('Profile completeness')
      end
    end
  end
end
