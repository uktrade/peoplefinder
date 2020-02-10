# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonUpdater, type: :service do
  subject do
    described_class.new(
      person: person,
      instigator: instigator,
      profile_url: 'https://example.com',
      state_cookie: smc
    )
  end

  let(:person) do
    double(
      Person,
      save!: true,
      new_record?: false,
      notify_of_change?: false,
      name: 'Jane Test',
      email: 'jane@example.com'
    )
  end

  let(:instigator) { double('Current User', name: 'Insti Gator') }

  context 'Saving profile on update' do
    let(:notify) { instance_double(GovukNotify, updated_profile: true) }
    let(:smc) { double StateManagerCookie, save_profile?: true, create?: false }

    before do
      allow(GovukNotify).to receive(:new).and_return(notify)
    end

    describe 'initialize' do
      it 'raises an exception if person is a new record' do
        allow(person).to receive(:new_record?).and_return(true)
        expect { subject }.to raise_error(/Cannot update a new Person record/)
      end
    end

    describe 'update!' do
      it 'saves the person' do
        expect(person).to receive(:save!)
        subject.update!
      end

      it 'sends an update email if required' do
        expect(person).to receive(:notify_of_change?).and_return(true)
        expect(notify).to receive(:updated_profile).with(
          'jane@example.com',
          recipient_name: 'Jane Test',
          instigator_name: 'Insti Gator',
          profile_url: 'https://example.com'
        )
        subject.update!
      end

      it 'sends no update email if not required' do
        allow(person)
          .to receive(:notify_of_change?)
          .with(instigator)
          .and_return(false)
        expect(notify).not_to receive(:updated_profile)
        subject.update!
      end
    end
  end
end
