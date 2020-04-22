# frozen_string_literal: true

require 'rails_helper'

describe Mailchimp do
  subject { described_class.new(mailchimp_client: mailchimp_client) }

  let(:mailchimp_client) { instance_double('Mailchimp client') }
  let(:mailchimp_list) { double('Mailchimp list') }
  let(:member) { double('Mailchimp list members', upsert: true, delete: true, tags: tags, retrieve: member_response) }
  let(:member_response) { double('Mailchimp member response', body: body) }
  let(:tags) { double('Mailchimp tags', create: true) }
  let(:body) { { 'tags' => [{ 'name' => 'tag1' }, { 'name' => 'tag2' }] } }

  before do
    allow(mailchimp_client).to receive(:lists).with('f00').and_return(mailchimp_list)

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
  end
end
