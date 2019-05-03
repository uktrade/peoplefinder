# frozen_string_literal: true

require 'rails_helper'

describe 'Management flow' do
  let(:email) { 'test.user@digital.justice.gov.uk' }
  let(:base_page) { Pages::Base.new }
  let(:management_page) { Pages::Management.new }

  let(:file) { CsvPublisher::UserBehaviorReport.default_file_path }
  let(:delete_report) do
    File.delete(file) if File.exist?(file)
  end

  before do
    omni_auth_log_in_as_super_admin
  end

  it 'When a super admin logis in they have a manage link' do
    expect(base_page).to have_manage_link
  end

  it 'Super admins can navigate to the management page' do
    expect(base_page).to have_manage_link
    click_link 'Manage'
    expect(management_page).to be_displayed
    expect(management_page).to be_all_there
  end

  describe 'Reports' do
    before { delete_report }

    after { delete_report }

    before do
      click_link 'Manage'
    end

    it 'can be generated' do
      expect do
        click_link 'generate'
      end.to have_enqueued_job(GenerateReportJob)
    end

    it 'can be downloaded', skip: 'until we can implement an approrpiate web driver for testing downloads' do
      click_link 'generate'
      expect(ActionController::DataStreaming).to receive(:send_file)
      within('#user-behavior-report') { click_link 'download' }
    end

    it 'Warns user that report needs generating first if one does not exist' do
      expect(File.exist?(file)).to be false
      within('#user-behavior-report') { click_link 'download' }
      expect(management_page).to have_flash_message(text: 'not been generated')
    end
  end
end
