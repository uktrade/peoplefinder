# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonUpdater, type: :service do
  subject { described_class.new(person: person, instigator: instigator, state_cookie: smc) }

  let(:person) do
    double(
      'Person',
      all_changes: { email: ['test.user@digital.justice.gov.uk', 'changed.user@digital.justice.gov.uk'], membership_12: { group_id: [1, nil] } },
      save!: true,
      new_record?: false,
      notify_of_change?: false
    )
  end

  let(:instigator) { double('Current User', email: 'user@example.com') }

  context 'Saving profile on update' do
    let(:smc) { double StateManagerCookie, save_profile?: true, create?: false }

    describe 'initialize' do
      it 'raises an exception if person is a new record' do
        allow(person).to receive(:new_record?).and_return(true)
        expect { subject }.to raise_error(PersonUpdater::NewRecordError)
      end
    end

    describe 'valid?' do
      it 'delegates valid? to the person' do
        validity = double
        expect(person).to receive(:valid?).and_return(validity)
        expect(subject.valid?).to eq(validity)
      end
    end

    describe 'update!' do
      let(:mailer) { double('mailer') }

      it 'saves the person' do
        expect(person).to receive(:save!)
        subject.update!
      end

      it 'sends an update email if required' do
        expect(person).to receive(:notify_of_change?).and_return(true)
        expect(UserUpdateMailer).to receive(:updated_profile_email).with(
          person,
          'user@example.com'
        ).and_return(mailer)
        expect(mailer).to receive(:deliver_later)
        subject.update!
      end

      it 'sends no update email if not required' do
        allow(person)
          .to receive(:notify_of_change?)
          .with(instigator)
          .and_return(false)
        expect(UserUpdateMailer).not_to receive(:updated_profile_email)
        subject.update!
      end
    end
  end
end
