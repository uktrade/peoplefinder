# frozen_string_literal: true

require 'rails_helper'

describe 'Login flow' do
  let!(:department) { create(:department) }

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:profile_page) { Pages::Profile.new }

  it 'When a user logs in for the first time, they are directed to edit their profile' do
    omni_auth_log_in_as('007')
    expect(edit_profile_page).to be_displayed
  end

  it 'When an existing user logs in, their profile page is displayed' do
    login_count = 5
    create(:person_with_multiple_logins, ditsso_user_id: '007', login_count: login_count)
    omni_auth_log_in_as('007')
    expect(profile_page).to be_displayed
  end

  it 'Login counter is updated every time user logs in' do
    login_count = 3
    person = create(:person_with_multiple_logins, ditsso_user_id: '007', login_count: login_count)
    omni_auth_log_in_as('007')
    person.reload
    expect(person.login_count).to be(4)
  end
end
