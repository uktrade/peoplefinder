# frozen_string_literal: true

require 'rails_helper'

describe MailingLists::BulkSync do
  let(:mailing_list_service) { instance_double(MailingList, all_subscribers: remote_emails) }

  let(:remote_emails) { %w[person1@gov.uk person2@gov.uk person3@gov.uk person4@gov.uk] }
  let(:local_emails) { %w[person2@gov.uk person3@gov.uk person5@gov.uk] }

  let(:person1) { double('Person') }
  let(:person2) { double('Person') }

  before do
    allow(MailingLists::DeactivateSubscriber).to receive(:call).and_return(true)
    allow(MailingLists::CreateOrUpdateSubscriberForPerson).to receive(:call).and_return(true)
    allow(Raven).to receive(:capture_exception)
    allow(Person).to receive(:pluck).with(:email).and_return(local_emails)
    allow(Person).to receive(:find_each).and_yield(person1).and_yield(person2)
  end

  describe '#call' do
    subject! { described_class.call(mailing_list_service: mailing_list_service) }

    it 'deactivates subscribers that do not exist locally' do
      expect(MailingLists::DeactivateSubscriber).to have_received(:call).with(email: 'person1@gov.uk')
      expect(MailingLists::DeactivateSubscriber).to have_received(:call).with(email: 'person4@gov.uk')
    end

    it 'does not deactivate subscribers that still exist locally' do
      expect(MailingLists::DeactivateSubscriber).not_to have_received(:call).with(email: 'person2@gov.uk')
      expect(MailingLists::DeactivateSubscriber).not_to have_received(:call).with(email: 'person3@gov.uk')
      expect(MailingLists::DeactivateSubscriber).not_to have_received(:call).with(email: 'person5@gov.uk')
    end

    it 'creates/updates subscribers for all local people' do
      expect(MailingLists::CreateOrUpdateSubscriberForPerson).to have_received(:call).with(person: person1)
      expect(MailingLists::CreateOrUpdateSubscriberForPerson).to have_received(:call).with(person: person2)
    end
  end
end
