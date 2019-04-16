require 'rails_helper'

feature 'Person edit notifications' do
  include ActiveJobHelper

  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }

  let(:super_admin) { create(:super_admin) }

  before(:each, user: :regular) do
    omni_auth_log_in_as(person.ditsso_user_id)
  end

  before(:each, user: :super_admin) do
    omni_auth_log_in_as(super_admin.ditsso_user_id)
  end

  scenario 'Deleting a person with different email', user: :super_admin do
    person = create(:person, email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    expect { click_delete_profile }.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(last_email.subject).to eq('Your profile on DIT People Finder has been deleted')
    check_email_to_and_from(from: super_admin.email)
  end

  scenario 'Editing a person with different email', user: :regular do
    digital = create(:group, name: 'Digital')
    person = create(:person, :member_of, team: digital, given_name: 'Bob', surname: 'Smith', email: 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_edit_profile
    fill_in 'Last name', with: 'Smelly Pants'
    expect do
      click_button 'Save', match: :first
    end.to change { QueuedNotification.count }.by(1)
    expect(QueuedNotification.last.changes_hash['data']['raw']['surname']).to eq(["Smith", "Smelly Pants"])
  end

  scenario 'Editing a person with same email', user: :regular do
    visit person_path(person)
    click_edit_profile
    fill_in 'Last name', with: 'Smelly Pants'
    expect do
      click_button 'Save', match: :first
    end.not_to change { ActionMailer::Base.deliveries.count }
  end

  def check_email_to_and_from(from: 'test.user@digital.justice.gov.uk')
    expect(last_email.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(last_email.body.encoded).to match(from)
  end
end
