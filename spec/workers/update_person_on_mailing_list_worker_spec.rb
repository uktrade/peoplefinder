# frozen_string_literal: true

require 'rails_helper'

describe UpdatePersonOnMailingListWorker do
  let(:mailchimp_service) { instance_double(Mailchimp, deactivate_subscriber: true, create_or_update_subscriber: true, set_subscriber_tags: true) }

  describe '#perform' do
    subject! { described_class.new(mailchimp_service: mailchimp_service).perform('per.son@trade.gov.uk', previous_email, 'Per', 'Son', %w[tag1 tag2]) }

    let(:previous_email) { nil }

    it 'sets tags for the user' do
      expect(mailchimp_service).to have_received(:set_subscriber_tags).with('per.son@trade.gov.uk', tags: %w[tag1 tag2])
    end

    it 'creates/updates the new email' do
      expect(mailchimp_service).not_to have_received(:deactivate_subscriber)
      expect(mailchimp_service).to have_received(:create_or_update_subscriber).with(
        'per.son@trade.gov.uk',
        merge_fields: { FNAME: 'Per', LNAME: 'Son' }
      )
    end

    context 'when a previous email is given' do
      let(:previous_email) { 'previous@trade.gov.uk' }

      it 'deactivates the previous email and creates/updates the new email' do
        expect(mailchimp_service).to have_received(:deactivate_subscriber).with('previous@trade.gov.uk')
        expect(mailchimp_service).to have_received(:create_or_update_subscriber).with(
          'per.son@trade.gov.uk',
          merge_fields: { FNAME: 'Per', LNAME: 'Son' }
        )
      end
    end
  end
end
