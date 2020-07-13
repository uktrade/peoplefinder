# frozen_string_literal: true

require 'rails_helper'

describe UpdateProfile do
  let(:person) do
    instance_double(
      Person,
      id: 42,
      name: 'Per Son',
      given_name: 'Per',
      surname: 'Son',
      assign_attributes: true,
      save!: true,
      valid?: valid,
      touch: true
    )
  end
  let(:instigator) { instance_double(Person, name: 'Insti Gator', role_administrator?: false) }
  let(:person_attributes) { double('Attributes') }
  let(:notifier) { instance_double(GovukNotify, updated_profile: true) }
  let(:notify_of_change) { false }
  let(:enable_external_integrations) { true }

  before do
    allow(person).to receive(:notify_of_change?).with(instigator).and_return(notify_of_change)
    allow(person).to receive(:email).and_return('person@gov.uk', 'person@example.com')
    allow(MailingLists::CreateOrUpdateSubscriberForPersonWorker).to receive(:perform_async)
    allow(MailingLists::DeactivateSubscriberWorker).to receive(:perform_async)
    allow(Rails.configuration).to receive(:enable_external_integrations).and_return(enable_external_integrations)
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

      it 'does not queue any mailing list workers' do
        expect(MailingLists::DeactivateSubscriberWorker).not_to have_received(:perform_async)
        expect(MailingLists::CreateOrUpdateSubscriberForPersonWorker).not_to have_received(:perform_async)
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

      it 'queues a worker to remove the previous email address from the mailing list' do
        expect(MailingLists::DeactivateSubscriberWorker).to have_received(:perform_async).with('person@gov.uk')
      end

      it 'queues a mailing list update workers for the person' do
        expect(MailingLists::CreateOrUpdateSubscriberForPersonWorker).to have_received(:perform_async).with(42)
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

      context 'when external integrations are disabled' do
        let(:enable_external_integrations) { false }

        it 'does not queue any mailing list workers' do
          expect(MailingLists::DeactivateSubscriberWorker).not_to have_received(:perform_async)
          expect(MailingLists::CreateOrUpdateSubscriberForPersonWorker).not_to have_received(:perform_async)
        end

        context 'when the updated person should be notified of changes' do
          let(:notify_of_change) { true }

          it 'does not send any emails' do
            expect(notifier).not_to have_received(:updated_profile)
          end
        end
      end
    end
  end
end
