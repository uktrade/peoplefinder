# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendNotificationsJob, type: :job do
  subject(:job) { described_class.new }

  let(:perform_later) { described_class.perform_later }

  let(:perform_now) { described_class.perform_now }

  context 'when enqueued' do
    it 'enqueues with appropriate config settings' do
      expect(job.queue_name).to eq 'send_notifications'
      expect(job.max_run_time).to eq 10.minutes
      expect(job.max_attempts).to eq 3
      expect(job.destroy_failed_jobs?).to eq false
    end

    it 'enqueues job with expected arguments' do
      expect do
        perform_later
      end.to have_enqueued_job(described_class)
    end

    it 'enqueues on named queue' do
      expect do
        perform_later
      end.to have_enqueued_job(described_class).on_queue('send_notifications')
    end
  end

  context 'when performed' do
    it 'invokes the NotificationSender and Geckoboard publishers' do
      mock_sender = double('NotificationSender')
      mock_publisher = double('Publisher')

      expect(NotificationSender).to receive(:new).and_return(mock_sender)
      expect(mock_sender).to receive(:send!)

      expect(GeckoboardPublisher::PhotoProfilesReport).to receive(:new).and_return(mock_publisher)
      expect(GeckoboardPublisher::ProfilesPercentageReport).to receive(:new).and_return(mock_publisher)
      expect(GeckoboardPublisher::TotalProfilesReport).to receive(:new).and_return(mock_publisher)
      expect(GeckoboardPublisher::ProfilesChangedReport).to receive(:new).and_return(mock_publisher)
      expect(GeckoboardPublisher::ProfileCompletionsReport).to receive(:new).and_return(mock_publisher)

      expect(mock_publisher).to receive(:publish!).with(true).exactly(5).times

      perform_now
    end
  end
end
