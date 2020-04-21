# frozen_string_literal: true

require 'rails_helper'

describe RemovePerson do
  let(:person) { instance_double(Person, email: 'good@bye.com', name: 'Good Bye', destroy!: true) }
  let(:notifier) { instance_double(GovukNotify, deleted_profile: true) }
  let(:mailing_list_integration_enabled) { true }

  before do
    allow(RemovePersonFromMailingListWorker).to receive(:perform_async)
    allow(Rails.configuration).to receive(:mailing_list_integration_enabled).and_return(mailing_list_integration_enabled)
  end

  describe '.call' do
    subject!(:context) { described_class.call(person: person, notifier: notifier) }

    it 'succeeds' do
      expect(context).to be_a_success
    end

    it 'destroys the person record' do
      expect(person).to have_received(:destroy!)
    end

    it 'queues a RemovePersonFromMailingListWorker with the previous email' do
      expect(RemovePersonFromMailingListWorker).to have_received(:perform_async).with('good@bye.com')
    end

    it 'sends an email to the deleted person to let them know they have been deleted' do
      expect(notifier).to have_received(:deleted_profile).with('good@bye.com', recipient_name: 'Good Bye')
    end

    context 'when mailing list integration is disabled' do
      let(:mailing_list_integration_enabled) { false }

      it 'does not queue a RemovePersonFromMailingListWorker' do
        expect(RemovePersonFromMailingListWorker).not_to have_received(:perform_async)
      end
    end
  end
end
