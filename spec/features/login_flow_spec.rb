# frozen_string_literal: true

require 'rails_helper'

describe 'Login flow' do
  let!(:department) { create(:department) }

  it 'When a user logs in for the first time, they are directed to edit their profile' do
    omni_auth_log_in_as('007')
    expect(page).to have_css('h1', text: 'Edit profile')
  end

  it 'When an existing user logs in, their profile page is displayed' do
    login_count = 5
    person = create(:person_with_multiple_logins, ditsso_user_id: '007', login_count: login_count)
    omni_auth_log_in_as('007')
    expect(page).to have_css('h1', text: person.name)
  end

  it 'Login counter is updated every time user logs in' do
    login_count = 3
    person = create(:person_with_multiple_logins, ditsso_user_id: '007', login_count: login_count)
    omni_auth_log_in_as('007')
    person.reload
    expect(person.login_count).to be(4)
  end
end
