# frozen_string_literal: true

Elasticsearch::Model.client = Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url)
