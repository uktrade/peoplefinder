if Rails.env.production?
  vcap_elasticsearch = JSON.parse(ENV['VCAP_SERVICES'])['elasticsearch'].first
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: vcap_elasticsearch['credentials']['uri'])
elsif Rails.configuration.elastic_search_url
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url)
end
