# frozen_string_literal: true

require 'rails_helper'

describe LoginPerson do
  let(:oauth_hash) do
    {
      'uid' => 'cafe0123',
      'info' => {
        'email' => 'example@example.com',
        'first_name' => 'exam',
        'last_name' => 'ple'
      }
    }
  end
  let(:time) { Time.now.in_time_zone }

  before do
    allow(Person).to receive(:find_or_initialize_by).with(ditsso_user_id: 'cafe0123').and_return(person)
  end

  describe '.call' do
    subject!(:context) do
      Timecop.freeze(time) do
        described_class.call(
          oauth_hash: oauth_hash
        )
      end
    end

    context 'for a person that does not exist' do
      let(:person) { Person.new }

      it 'adds the person to the context' do
        expect(context.person).to eq(person)
      end

      it 'saves the person' do
        expect(person).to be_persisted
        expect(person).not_to be_changed
      end

      it 'sets profile attributes from SSO' do
        expect(person.ditsso_user_id).to eq('cafe0123')
        expect(person.email).to eq('example@example.com')
        expect(person.given_name).to eq('Exam')
        expect(person.surname).to eq('Ple')
      end

      it 'sets the login count and timestamp' do
        expect(person.login_count).to eq(1)
        expect(person.last_login_at).to be_within(1.second).of(time)
      end

      it 'sets the redirect_to_edit flag to true' do
        expect(context.redirect_to_edit).to eq(true)
      end
    end

    context 'for a person that exists' do
      let(:person) { create(:person, login_count: 6) }

      it 'adds the person to the context' do
        expect(context.person).to eq(person)
      end

      it 'saves the person' do
        expect(person).not_to be_changed
      end

      it 'updates the login count and timestamp' do
        expect(person.login_count).to eq(7)
        expect(person.last_login_at).to be_within(1.second).of(time)
      end

      it 'sets the redirect_to_edit flag to false' do
        expect(context.redirect_to_edit).to eq(false)
      end
    end
  end
end
