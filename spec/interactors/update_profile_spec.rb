# frozen_string_literal: true

require 'rails_helper'

describe UpdateProfile do
  let(:person) do
    instance_double(
      Person,
      name: 'Per Son',
      given_name: 'Per',
      surname: 'Son',
      building: ['', 'skyscraper', 'airport'],
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
  let(:mailing_list_integration_enabled) { true }

  before do
    allow(person).to receive(:notify_of_change?).with(instigator).and_return(notify_of_change)
    allow(person).to receive(:email).and_return('person@gov.uk', 'person@example.com')
    allow(UpdatePersonOnMailingListWorker).to receive(:perform_async)
    allow(Rails.configuration).to receive(:mailing_list_integration_enabled).and_return(mailing_list_integration_enabled)
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

      it 'queues an UpdatePersonOnMailingListWorker with the previous email' do
        expect(UpdatePersonOnMailingListWorker).to have_received(:perform_async).with(
          'person@example.com',
          'person@gov.uk',
          'Per',
          'Son',
          %w[pf_imported pf_building_skyscraper pf_building_airport]
        )
      end

      it 'touches the last_edited_or_confirmed_at timestamp' do
        expect(person).to have_received(:touch).with(:last_edited_or_confirmed_at)
      end

      context 'when mailing list integration is disabled' do
        let(:mailing_list_integration_enabled) { false }

        it 'does not queue an UpdatePersonOnMailingListWorker' do
          expect(UpdatePersonOnMailingListWorker).not_to have_received(:perform_async)
        end
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
