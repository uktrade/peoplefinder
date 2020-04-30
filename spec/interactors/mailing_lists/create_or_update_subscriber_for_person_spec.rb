# frozen_string_literal: true

require 'rails_helper'

describe MailingLists::CreateOrUpdateSubscriberForPerson do
  let(:person) { instance_double(Person, email: 'mail@chimp.com', given_name: 'Mail', surname: 'Chimp', building: ['', 'skyscraper', 'airport']) }
  let(:mailing_list_service) { instance_double(MailingList, deactivate_subscriber: true, create_or_update_subscriber: true, set_subscriber_tags: true) }

  describe '.call' do
    subject!(:context) { described_class.call(person: person, mailing_list_service: mailing_list_service) }

    it 'creates/updates the subscriber and sets tags' do
      expect(mailing_list_service).to have_received(:create_or_update_subscriber).with(
        'mail@chimp.com',
        merge_fields: { FNAME: 'Mail', LNAME: 'Chimp' }
      )

      expect(mailing_list_service).to have_received(:set_subscriber_tags).with('mail@chimp.com', tags: %w[pf_imported pf_building_skyscraper pf_building_airport])
    end
  end
end
