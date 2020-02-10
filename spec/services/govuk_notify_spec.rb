# frozen_string_literal: true

require 'rails_helper'

describe GovukNotify, type: :service do
  let(:client) { instance_double(Notifications::Client) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(client)
  end

  describe '#updated_profile' do
    it 'sends the expected email' do
      expect(client).to receive(:send_email).with(
        email_address: 'foo@bar.com',
        template_id: 'acfdc019-22d1-4281-aab9-3f64764425ac',
        personalisation: {
          recipient_name: 'Foo Bar',
          instigator_name: 'Bar Foo',
          profile_url: 'https://www.gov.uk'
        }
      )

      subject.updated_profile(
        'foo@bar.com',
        recipient_name: 'Foo Bar',
        instigator_name: 'Bar Foo',
        profile_url: 'https://www.gov.uk'
      )
    end
  end

  describe '#deleted_profile' do
    it 'sends the expected email' do
      expect(client).to receive(:send_email).with(
        email_address: 'foo@bar.com',
        template_id: '92a1992f-96d7-4f59-af30-e2432aa004d0',
        personalisation: {
          recipient_name: 'Foo Bar'
        }
      )

      subject.deleted_profile(
        'foo@bar.com',
        recipient_name: 'Foo Bar'
      )
    end
  end
end
