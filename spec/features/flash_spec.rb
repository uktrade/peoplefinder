# frozen_string_literal: true

require 'rails_helper'

describe 'Flash messages' do
  let(:department) { create(:department) }

  before do
    omni_auth_log_in_as_administrator
  end

  it 'displays flash messages below search box' do
    visit group_path(department)
    click_link 'Add new sub-team'
    fill_in 'Team name', with: 'Digital'
    click_button 'Save'

    within('#flash-messages') do
      expect(page).to have_content('Created Digital')
    end
  end
end
