# frozen_string_literal: true

require 'rails_helper'

describe RemovePerson do
  let(:person) { instance_double(Person, email: 'good@bye.com', name: 'Good Bye', destroy!: true) }
  let(:notifier) { instance_double(GovukNotify, deleted_profile: true) }

  before do
    allow(MailingLists::DeactivateSubscriberWorker).to receive(:perform_async)
  end

  describe '.call' do
    subject!(:context) { described_class.call(person: person, notifier: notifier) }

    it 'succeeds' do
      expect(context).to be_a_success
    end

    it 'destroys the person record' do
      expect(person).to have_received(:destroy!)
    end

    it 'queues a MailingLists::DeactivateSubscriberWorker with the previous email' do
      expect(MailingLists::DeactivateSubscriberWorker).to have_received(:perform_async).with('good@bye.com')
    end

    it 'sends an email to the deleted person to let them know they have been deleted' do
      expect(notifier).to have_received(:deleted_profile).with('good@bye.com', recipient_name: 'Good Bye')
    end
  end
end
