# frozen_string_literal: true

require 'rails_helper'

describe MailingLists::CreateOrUpdateSubscriberForPerson do
  let(:person) { instance_double(Person) }
  let(:decorated_person) { double('decorated person', email: 'mail@chimp.com', tags: ['tag'], merge_fields: { 'merge' => 'field' }) }

  let(:mailing_list_service) { instance_double(MailingList, deactivate_subscriber: true, create_or_update_subscriber: true, set_subscriber_tags: true) }

  before do
    allow(MailingListPersonDecorator).to receive(:new).with(person).and_return(decorated_person)
  end

  describe '.call' do
    subject!(:context) { described_class.call(person: person, mailing_list_service: mailing_list_service) }

    it 'creates/updates the subscriber and sets tags' do
      expect(mailing_list_service).to have_received(:create_or_update_subscriber).with(
        'mail@chimp.com',
        merge_fields: { 'merge' => 'field' }
      )

      expect(mailing_list_service).to have_received(:set_subscriber_tags).with('mail@chimp.com', tags: ['tag'])
    end
  end
end
