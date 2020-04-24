# frozen_string_literal: true

require 'rails_helper'

describe UpdateProfile do
  let(:person) do
    instance_double(
      Person,
      name: 'Per Son',
      given_name: 'Per',
      surname: 'Son',
      assign_attributes: true,
      save!: true,
      valid?: valid,
      touch: true
    )
  end
  let(:instigator) { instance_double(Person, name: 'Insti Gator') }
  let(:person_attributes) { double('Attributes') }
  let(:notifier) { instance_double(GovukNotify, updated_profile: true) }
  let(:notify_of_change) { false }

  before do
    allow(person).to receive(:notify_of_change?).with(instigator).and_return(notify_of_change)
    allow(person).to receive(:email).and_return('person@gov.uk', 'person@example.com')
    allow(UpdatePersonOnMailingList).to receive(:call)
  end

  describe '.call' do
    subject!(:context) do
      described_class.call(
        person: person,
        person_attributes: person_attributes,
        profile_url: 'http://example.com/profile',
        instigator: instigator,
        notifier: notifier
      )
    end

    context 'when the person is not valid' do
      let(:valid) { false }

      it 'fails' do
        expect(context).to be_a_failure
      end

      it 'does not save the Person record' do
        expect(person).not_to have_received(:save!)
      end

      it 'does not touch the last_edited_or_confirmed_at timestamp' do
        expect(person).not_to have_received(:touch)
      end

      it 'does not send an email to the updated user' do
        expect(notifier).not_to have_received(:updated_profile)
      end

      it 'does not update the user on the mailing list' do
        expect(UpdatePersonOnMailingList).not_to have_received(:call)
      end
    end

    context 'when the person is valid' do
      let(:valid) { true }

      it 'succeeds' do
        expect(context).to be_a_success
      end

      it 'updates and saves the Person record' do
        expect(person).to have_received(:assign_attributes).with(person_attributes)
        expect(person).to have_received(:save!)
      end

      it 'does not send an email to the updated user by default' do
        expect(notifier).not_to have_received(:updated_profile)
      end

      it 'touches the last_edited_or_confirmed_at timestamp' do
        expect(person).to have_received(:touch).with(:last_edited_or_confirmed_at)
      end

      it 'updates the person on the mailing list' do
        expect(UpdatePersonOnMailingList).to have_received(:call).with(person: person, previous_email: 'person@gov.uk')
      end

      context 'when the updated person should be notified of changes' do
        let(:notify_of_change) { true }

        it 'sends an email to them to let them know their profile has been edited' do
          expect(notifier).to have_received(:updated_profile).with(
            'person@example.com',
            recipient_name: 'Per Son',
            instigator_name: 'Insti Gator',
            profile_url: 'http://example.com/profile'
          )
        end
      end
    end
  end
end
