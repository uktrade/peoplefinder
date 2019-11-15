# frozen_string_literal: true

module HealthCheck
  class ElasticsearchHealthCheck
    extend BaseHealthCheck

    def self.check
      res = Elasticsearch::Model.client.ping
      res == true ? '' : "Elasticsearch ping returned #{res.inspect} instead of true"
    rescue StandardError => e
      create_error 'elasticsearch', e.message
    end
  end
end
