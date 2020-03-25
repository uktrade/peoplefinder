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
    expect(base_page).to have_manage_link
  end

  it 'Administrators can navigate to the management page' do
    expect(base_page).to have_manage_link
    click_link 'Manage'
    expect(management_page).to be_displayed
    expect(management_page).to be_all_there
  end
end
