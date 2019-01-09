require 'rails_helper'

feature 'Cookie message', js: true do
  let(:message_text) { 'GOV.UK uses cookies to make the site simpler' }
  let(:cookie_banner) { page.find('#global-cookie-message') }

  scenario 'first visit' do
    visit '/'
    expect(cookie_banner).to be_visible

    click_link 'Find out more about cookies'
    expect(page).to have_content('How cookies are used on People Finder')
  end

  scenario 'subsequent visits' do
    visit '/'
    visit '/'
    expect(cookie_banner).to_not be_visible
  end
end
