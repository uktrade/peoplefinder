require 'faraday_middleware/aws_signers_v4'

if Rails.env.production?
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url) do |faraday|
    faraday.request :aws_signers_v4,
      credentials: Aws::Credentials.new(Rails.configuration.aws_elastic_key, Rails.configuration.aws_elastic_secret),
      service_name: 'es',
      region: Rails.configuration.aws_elastic_region

    faraday.response :json, :content_type => /\bjson\b/
    faraday.response :raise_error
    faraday.adapter Faraday.default_adapter
  end
end
