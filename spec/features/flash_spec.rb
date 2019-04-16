require 'rails_helper'

feature 'Flash messages' do
  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      page.body.index(earlier_content) < page.body.index(later_content)
    end
  end

  describe 'layout' do
    let!(:dept) { create :department }
    let(:person) { create :person }
    let(:flash_messages) { 'flash-messages' }
    let(:searchbox) { 'mod-search-form' }
    let(:super_admin) { create(:super_admin) }

    before do
      omni_auth_log_in_as_super_admin
      person.memberships.destroy_all
    end

    scenario 'display flash messages above search box for home page' do
      visit person_path(person)
      click_delete_profile
      expect(flash_messages).to appear_before searchbox
      expect(searchbox).not_to appear_before flash_messages
    end

    scenario 'display flash messages below search box' do
      visit group_path(dept)
      click_link 'Add new sub-team'
      fill_in 'Team name', with: 'Digital'
      click_button 'Save'
      expect(searchbox).not_to appear_before flash_messages
      expect(flash_messages).to appear_before searchbox
    end
  end
end
