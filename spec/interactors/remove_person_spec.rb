# frozen_string_literal: true

require 'rails_helper'

describe RemovePerson do
  let(:person) { instance_double(Person, email: 'good@bye.com', name: 'Good Bye', destroy!: true) }
  let(:notifier) { instance_double(GovukNotify, deleted_profile: true) }
  let(:enable_external_integrations) { true }

  before do
    allow(MailingLists::DeactivateSubscriberWorker).to receive(:perform_async)
    allow(Rails.configuration).to receive(:enable_external_integrations).and_return(enable_external_integrations)
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

    context 'when external integrations are disabled' do
      let(:enable_external_integrations) { false }

      it 'does not queue any mailing list workers' do
        expect(MailingLists::DeactivateSubscriberWorker).not_to have_received(:perform_async)
      end

      it 'does not send any emails' do
        expect(notifier).not_to have_received(:deleted_profile)
      end
    end
  end
end
