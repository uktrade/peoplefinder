# frozen_string_literal: true

require 'rails_helper'

describe 'OmniAuth Authentication' do
  let(:group) { create(:group) }

  let(:login_page) { Pages::Login.new }
  let(:profile_page) { Pages::Profile.new }
  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:group_page) { Pages::Group.new }

  before do
    OmniAuth.config.test_mode = true
  end

  it 'Logging in and out' do
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user

    visit '/'

    # and verifying that the SSO user ID
    expect(Person.last.ditsso_user_id).to eq(valid_user[:uid].to_s)
  end

  it 'Logging in when the user has no last_name' do
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user_no_last_name

    visit '/'
    expect(page).to have_text('Hi, John')
  end

  it 'Non existent users are redirected to their new profiles edit page after logging in' do
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user
    visit group_path(group)
    expect(edit_profile_page).to be_displayed
  end

  it 'Existing users are redirected to their desired path after logging in' do
    create(:person, ditsso_user_id: 'beef')
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user
    visit group_path(group)
    expect(group_page).to be_displayed
  end
end

def valid_user
  OmniAuth::AuthHash.new(
    provider: 'ditsso_internal',
    uid: 'beef',
    info: {
      user_id: 'beef',
      email: 'test.user@digital.justice.gov.uk',
      first_name: 'john',
      last_name: 'doe'
    }
  )
end

def valid_user_no_last_name
  OmniAuth::AuthHash.new(
    provider: 'ditsso_internal',
    uid: 'bad',
    info: {
      user_id: 'bad',
      email: 'test.user@digital.justice.gov.uk',
      first_name: 'John',
      last_name: ''
    }
  )
end
