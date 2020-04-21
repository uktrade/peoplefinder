# frozen_string_literal: true

require 'rails_helper'

describe RemovePersonFromMailingListWorker do
  let(:mailchimp_service) { instance_double(Mailchimp, deactivate_subscriber: true) }

  describe '#perform' do
    subject! { described_class.new.perform('bye.bye@trade.gov.uk', mailchimp_service) }

    context 'when a previous email is given' do
      it 'deactivates the subscribed' do
        expect(mailchimp_service).to have_received(:deactivate_subscriber).with('bye.bye@trade.gov.uk')
      end
    end
  end
end
