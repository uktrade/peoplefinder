require 'rails_helper'

feature 'Log out' do
  include PermittedDomainHelper

  before do
    ENV['HOME_PAGE_URL'] = 'http://workspace.local'
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  after do
    ENV['HOME_PAGE_URL'] = nil
  end

  scenario 'in general' do # logging out is handled by the work space
    expect(page).to have_link('Log out', href: 'http://workspace.local/logout')
  end
end
