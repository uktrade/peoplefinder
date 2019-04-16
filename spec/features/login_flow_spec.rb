require 'rails_helper'

feature 'Login flow' do
  let!(:department) { create(:department) }

  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:profile_page) { Pages::Profile.new }
  let(:base_page) { Pages::Base.new }

  describe 'Choosing to login' do
    scenario 'When a user logs in for the first time, they are directed to edit their profile' do
      omni_auth_log_in_as('007')
      expect(edit_profile_page).to be_displayed
    end

    scenario 'When and existing user logs in, their profile page is displayed' do
      login_count = 5
      create(:person_with_multiple_logins, ditsso_user_id: '007', login_count: login_count)
      omni_auth_log_in_as('007')
      expect(profile_page).to be_displayed
    end

    scenario 'Login counter is updated every time user logs in' do
      login_count = 3
      person = create(:person_with_multiple_logins, ditsso_user_id: '007', login_count: login_count)
      omni_auth_log_in_as('007')
      person.reload
      expect(person.login_count).to eql(4)
    end

    scenario 'When super user logs in they see the manage link in the banner' do
      omni_auth_log_in_as_super_admin
      expect(base_page).to have_manage_link
    end

    scenario 'When a normal user logs in they do not see the manage link in the banner' do
      omni_auth_log_in_as('007')
      expect(base_page).to have_no_manage_link
    end
  end
end
