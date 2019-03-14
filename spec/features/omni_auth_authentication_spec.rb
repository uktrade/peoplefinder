require 'rails_helper'

feature 'OmniAuth Authentication' do
  let(:group) { create(:group) }

  let(:login_page) { Pages::Login.new }
  let(:profile_page) { Pages::Profile.new }
  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:group_page) { Pages::Group.new }

  before do
    OmniAuth.config.test_mode = true
  end

  scenario 'Logging in and out' do
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user

    visit '/'

    # and verifying that the internal auth key has been set
    expect(Person.last.internal_auth_key).to eq(valid_user[:info][:email].to_s)
  end

  scenario 'Logging in when the user has no last_name' do
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user_no_last_name

    visit '/'
    expect(page).to have_text('Hi, John')
  end

  scenario 'Logging in when the user has an existing account from another provider' do
    person = create(:person, given_name: 'Alice', email: valid_user[:info][:email])
    person.update_column(:internal_auth_key, 'alice@example.com') # rubocop:disable Rails/SkipsModelValidations
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user

    visit '/'
    expect(page).to have_text('Hi, Alice')
    expect(person.reload.internal_auth_key).to eq(valid_user[:info][:email].to_s)
  end

  scenario 'Logging in when the user has an account that was created by another person' do
    person = create(:person, given_name: 'Alice', email: valid_user[:info][:email])
    person.update_column(:internal_auth_key, nil) # rubocop:disable Rails/SkipsModelValidations
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user

    visit '/'
    expect(page).to have_text('Hi, Alice')
    expect(person.reload.internal_auth_key).to eq(valid_user[:info][:email].to_s)
  end

  scenario 'Non existent users are redirected to their new profiles edit page after logging in' do
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user
    visit group_path(group)
    expect(edit_profile_page).to be_displayed
  end

  scenario 'Existing users are redirected to their desired path after logging in' do
    create(:person, email: valid_user[:info][:email])
    OmniAuth.config.mock_auth[:ditsso_internal] = valid_user
    visit group_path(group)
    expect(group_page).to be_displayed
  end
end

def valid_user
  OmniAuth::AuthHash.new(
    provider: 'ditsso_internal',
    info: {
      email: 'test.user@digital.justice.gov.uk',
      first_name: 'john',
      last_name: 'doe'
    }
  )
end

def valid_user_no_last_name
  OmniAuth::AuthHash.new(
    provider: 'ditsso_internal',
    info: {
      email: 'test.user@digital.justice.gov.uk',
      first_name: 'John',
      last_name: ''
    }
  )
end
