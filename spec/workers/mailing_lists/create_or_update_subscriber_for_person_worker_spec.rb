# frozen_string_literal: true

require 'rails_helper'

describe MailingLists::CreateOrUpdateSubscriberForPersonWorker do
  let(:person) { instance_double(Person) }

  before do
    allow(Person).to receive(:find_by).with(id: 42).and_return(person)
    allow(MailingLists::CreateOrUpdateSubscriberForPerson).to receive(:call)
  end

  describe '#perform' do
    subject! { described_class.new.perform(42) }

    it 'finds the person and calls the interactor' do
      expect(MailingLists::CreateOrUpdateSubscriberForPerson).to have_received(:call).with(person: person)
    end

    context 'when the person no longer exists' do
      let(:person) { nil }

      it 'does nothing' do
        expect(MailingLists::CreateOrUpdateSubscriberForPerson).not_to have_received(:call)
      end
    end
  end
end
