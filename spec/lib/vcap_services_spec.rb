# frozen_string_literal: true

require 'rails_helper'

describe VcapServices do
  subject { described_class.new(env_var) }

  let(:env_var) { file_fixture('vcap_services.json').read }

  describe '#service_url' do
    context 'when there is only one service of the given type' do
      let(:service_url) { subject.service_url(:elasticsearch) }

      it 'gets the url for the service of the given type' do
        expect(service_url).to eq('es_uri')
      end
    end

    context 'when there are multiple services of the given type' do
      let(:service_url) { subject.service_url(:redis) }

      it 'gets the url for the first service of the given type' do
        expect(service_url).to eq('redis_cache_uri')
      end
    end

    context 'when there are no services of the given type' do
      let(:service_url) { subject.service_url(:ms_sql_server_2008) }

      it 'returns nil' do
        expect(service_url).to be_nil
      end
    end
  end

  describe '#named_service_url' do
    context 'for a service with a binding name that exists' do
      let(:named_service_url) { subject.named_service_url(:redis, 'redis_sidekiq') }

      it 'gets the url for the service of the given type and binding name' do
        expect(named_service_url).to eq('redis_sidekiq_uri')
      end
    end

    context 'for a service with a binding name that does not exist' do
      let(:named_service_url) { subject.named_service_url(:redis, 'redis_foo') }

      it 'returns nil' do
        expect(named_service_url).to be_nil
      end
    end

    context 'when there are no services of the given type' do
      let(:named_service_url) { subject.named_service_url(:ms_sql_server_2008, 'foo') }

      it 'returns nil' do
        expect(named_service_url).to be_nil
      end
    end
  end
end
