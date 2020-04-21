# frozen_string_literal: true

require 'rails_helper'

describe UpdatePersonOnMailingListWorker do
  let(:mailchimp_service) { instance_double(Mailchimp, deactivate_subscriber: true, create_or_update_subscriber: true) }

  describe '#perform' do
    subject! { described_class.new.perform('per.son@trade.gov.uk', previous_email, 'Per', 'Son', mailchimp_service) }

    context 'when no previous email is given' do
      let(:previous_email) { nil }

      it 'creates/updates the new email' do
        expect(mailchimp_service).not_to have_received(:deactivate_subscriber)
        expect(mailchimp_service).to have_received(:create_or_update_subscriber).with(
          'per.son@trade.gov.uk',
          merge_fields: { FNAME: 'Per', LNAME: 'Son' }
        )
      end
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
