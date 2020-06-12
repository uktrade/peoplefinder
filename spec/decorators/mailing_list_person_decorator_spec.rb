# frozen_string_literal: true

require 'rails_helper'

describe MailingListPersonDecorator do
  subject { described_class.new(person) }

  let(:person) { build_stubbed(:person, email: email, given_name: 'Mail', surname: 'Chimp', building: ['', 'skyscraper', 'airport']) }
  let(:email) { 'mail@chimp.com' }

  describe '#merge_fields' do
    it 'returns the expected Mailchimp merge fields' do
      expect(subject.merge_fields).to eq({ FNAME: 'Mail', LNAME: 'Chimp' })
    end
  end

  describe '#tags' do
    it 'returns the expected Mailchimp tags' do
      expect(subject.tags).to contain_exactly('pf_imported', 'pf_building_skyscraper', 'pf_building_airport')
    end

    context 'when the person has an email address that should be included on the "main list"' do
      let(:email) { 'a.b@digital.trade.gov.uk' }

      it 'adds the appropriate tag' do
        expect(subject.tags).to include('group_onedit')
      end
    end
  end
end
