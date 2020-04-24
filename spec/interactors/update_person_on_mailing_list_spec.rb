# frozen_string_literal: true

require 'rails_helper'

describe UpdatePersonOnMailingList do
  let(:person) { instance_double(Person, email: 'person@example.com', given_name: 'Per', surname: 'Son', building: ['', 'skyscraper', 'airport']) }
  let(:mailing_list_integration_enabled) { true }

  before do
    allow(UpdatePersonOnMailingListWorker).to receive(:perform_async)
    allow(Rails.configuration).to receive(:mailing_list_integration_enabled).and_return(mailing_list_integration_enabled)
  end

  describe '.call' do
    subject!(:context) { described_class.call(person: person, previous_email: 'person@gov.uk') }

    it 'succeeds' do
      expect(context).to be_a_success
    end

    it 'queues an UpdatePersonOnMailingListWorker with the previous email' do
      expect(UpdatePersonOnMailingListWorker).to have_received(:perform_async).with(
        'person@example.com',
        'person@gov.uk',
        'Per',
        'Son',
        %w[pf_imported pf_building_skyscraper pf_building_airport]
      )
    end

    context 'when mailing list integration is disabled' do
      let(:mailing_list_integration_enabled) { false }

      it 'does not queue an UpdatePersonOnMailingListWorker' do
        expect(UpdatePersonOnMailingListWorker).not_to have_received(:perform_async)
      end
    end
  end
end
