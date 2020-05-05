# frozen_string_literal: true

require 'rails_helper'

describe 'Management flow' do
  context 'as an administrator' do
    before do
      omni_auth_log_in_as_administrator
    end

    it 'shows a "Manage" link in the menu' do
      expect(page).to have_link('Manage', href: admin_home_path)
    end

    it 'allows navigating to the management page' do
      click_link 'Manage'
      expect(page).to have_text('Manage People Finder')
    end

    it 'allows visiting the Sidekiq management UI' do
      visit admin_sidekiq_web_path
      expect(page).to have_text('Sidekiq')
    end
  end

  context 'as a regular user' do
    let!(:department) { create(:department) }

    before do
      omni_auth_log_in_as '007'
    end

    it 'does not show a "Manage" link in the menu' do
      expect(page).not_to have_link('Manage')
    end

    it 'does not allow visiting the management page' do
      visit admin_home_path
      expect(page).to have_current_path(group_path(department))
      expect(page).to have_text('Unauthorised, insufficient privileges')
    end

    it 'does not allow visiting the Sidekiq management UI' do
      expect { visit admin_sidekiq_web_path }.to raise_error(ActionController::RoutingError)
    end
  end
end
