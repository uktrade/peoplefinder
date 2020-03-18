# frozen_string_literal: true

require 'rails_helper'

describe 'Management flow' do
  let(:email) { 'test.user@digital.justice.gov.uk' }
  let(:base_page) { Pages::Base.new }
  let(:management_page) { Pages::Management.new }

  before do
    omni_auth_log_in_as_administrator
  end

  it 'When an administrator logs in they have a manage link' do
    expect(page).to have_link('Manage', href: admin_home_path)
  end

  it 'Administrators can navigate to the management page' do
    click_link 'Manage'
    expect(page).to have_text('Manage People Finder')
  end
end
