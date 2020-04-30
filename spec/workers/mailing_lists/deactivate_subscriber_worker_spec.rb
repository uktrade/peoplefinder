# frozen_string_literal: true

require 'rails_helper'

describe MailingLists::DeactivateSubscriberWorker do
  before do
    allow(MailingLists::DeactivateSubscriber).to receive(:call)
  end

  describe '#perform' do
    subject! { described_class.new.perform('mail@chimp.com') }

    it 'finds the person and calls the interactor' do
      expect(MailingLists::DeactivateSubscriber).to have_received(:call).with(email: 'mail@chimp.com')
    end
  end
end
