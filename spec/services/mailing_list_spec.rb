# frozen_string_literal: true

require 'rails_helper'

describe MailingList do
  subject { described_class.new(client: client, export_client: export_client) }

  let(:client) { instance_double('Mailchimp client') }
  let(:export_client) { instance_double('Mailchimp export client', list: list) }
  let(:mailchimp_list) { double('Mailchimp list') }
  let(:member) { double('Mailchimp list members', upsert: true, delete: true, tags: tags, retrieve: member_response) }
  let(:member_response) { double('Mailchimp member response', body: body) }
  let(:tags) { double('Mailchimp tags', create: true) }
  let(:body) { { 'tags' => [{ 'name' => 'tag1' }, { 'name' => 'tag2' }] } }
  let(:list) do
    [
      %w[HEADER1 HEADER2 HEADER3],
      %w[email1@gov.uk Blah Blah],
      %w[email2@gov.uk Blah Blah],
      %w[email3@gov.uk Blah Blah]
    ]
  end

  before do
    allow(client).to receive(:lists).with('f00').and_return(mailchimp_list)

    # MD5 of person@gov.uk (NB: lowercase!)
    allow(mailchimp_list).to receive(:members).with('c5b7d9bbe1941dbeb2e43df9b4ec6f79').and_return(member)

    allow(Rails.configuration).to receive(:mailchimp_list_id).and_return('f00')
  end

  describe '#create_or_update_subscriber' do
    it 'calls upsert on the client' do
      expect(member).to receive(:upsert).with(
        body: {
          email_address: 'Per.Son@GOV.uk',
          status: 'subscribed',
          merge_fields: {
            foo: 'bar',
            test: 'tset'
          }
        }
      )

      subject.create_or_update_subscriber('Per.Son@GOV.uk', merge_fields: { foo: 'bar', test: 'tset' })
    end

    # rubocop:disable RSpec/StubbedMock
    it 'does not fail on compliance errors' do
      err = Gibbon::MailChimpError.new('Nope', title: 'Member In Compliance State')
      expect(member).to receive(:upsert).and_raise(err)

      subject.create_or_update_subscriber('Per.Son@GOV.uk', merge_fields: { foo: 'bar', test: 'tset' })
    end
    # rubocop:enable RSpec/StubbedMock
  end

  describe '#set_subscriber_tags' do
    it 'sets the appropriate tags on the subscriber' do
      expect(tags).to receive(:create).with(
        body: {
          tags: [
            { name: 'tag2', status: 'inactive' },
            { name: 'tag1', status: 'active' },
            { name: 'tag3', status: 'active' }
          ]
        }
      )

      subject.set_subscriber_tags('Per.SON@gov.UK', tags: %w[tag1 tag3])
    end
  end

  describe '#deactivate_subscriber' do
    it 'calls upsert on the client' do
      expect(member).to receive(:delete)

      subject.deactivate_subscriber('PER.SON@GoV.uk')
    end

    context 'when the API returns an error' do
      before do
        allow(member).to receive(:delete).and_raise(error)
      end

      context '404' do
        # The user does not exist, retrying won't help
        let(:error) { Gibbon::MailChimpError.new('Not found', status_code: 404) }

        it 'returns false' do
          expect(subject.deactivate_subscriber('PER.SON@GoV.uk')).to eq(false)
        end
      end

      context '405' do
        # The user is already deactivated, retrying won't help
        let(:error) { Gibbon::MailChimpError.new('Cannot be removed', status_code: 405) }

        it 'returns false' do
          expect(subject.deactivate_subscriber('PER.SON@GoV.uk')).to eq(false)
        end
      end

      context 'any other error' do
        # The user is already deactivated, retrying won't help
        let(:error) { Gibbon::MailChimpError.new('Monkey see monkey do', status_code: 500) }

        it 're-raises the error' do
          expect { subject.deactivate_subscriber('PER.SON@GoV.uk') }.to raise_error(error)
        end
      end
    end
  end

  describe '#all_subscribers' do
    it 'returns an array of email addresses' do
      expect(subject.all_subscribers).to eq(%w[email1@gov.uk email2@gov.uk email3@gov.uk])
    end
  end
end
