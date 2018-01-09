require 'faraday_middleware/aws_signers_v4'

if Rails.env.production?
  transport_configuration = lambda do |f|
    f.request :aws_signers_v4,
      credentials: Aws::Credentials.new(Rails.configuration.aws_elastic_key, Rails.configuration.aws_elastic_secret),
      service_name: 'es',
      region: Rails.configuration.aws_elastic_region

    f.response :logger
    f.adapter  Faraday.default_adapter
  end
  transport = Elasticsearch::Transport::Transport::HTTP::Faraday.new url: Rails.configuration.elastic_search_url, &transport_configuration
  Elasticsearch::Model.client = Elasticsearch::Client.new transport: transport
end
