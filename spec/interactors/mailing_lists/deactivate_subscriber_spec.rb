# frozen_string_literal: true

require 'rails_helper'

describe MailingLists::DeactivateSubscriber do
  let(:mailing_list_service) { instance_double(MailingList, deactivate_subscriber: true) }

  describe '.call' do
    subject!(:context) { described_class.call(email: 'mail@chimp.com', mailing_list_service: mailing_list_service) }

    it 'deactivates the subscriber' do
      expect(mailing_list_service).to have_received(:deactivate_subscriber).with('mail@chimp.com')
    end
  end
end
