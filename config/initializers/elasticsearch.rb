require 'faraday_middleware/aws_signers_v4'

# TODO: Clean up once GOV.UK PaaS migration is complete
vcap_services = JSON.parse(ENV['VCAP_SERVICES']) if ENV['VCAP_SERVICES']
vcap_elasticsearch = vcap_services && vcap_services['elasticsearch']&.first

if Rails.env.production? && vcap_elasticsearch
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: vcap_elasticsearch['credentials']['uri'])
elsif Rails.env.production?
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url) do |faraday|
    faraday.request :aws_signers_v4,
      credentials: Aws::Credentials.new(Rails.configuration.aws_elastic_key, Rails.configuration.aws_elastic_secret),
      service_name: 'es',
      region: Rails.configuration.aws_elastic_region

    faraday.response :raise_error
    faraday.adapter Faraday.default_adapter
  end
elsif Rails.configuration.elastic_search_url
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url)
end
