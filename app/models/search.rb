# frozen_string_literal: true

class Search
  ES_MAX_RESULTS = 100
  ES_MIN_SCORE = 0.02
  ES_PRE_TAGS = ['<strong class="ws-person-search-result__highlight">'].freeze
  ES_POST_TAGS = ['</strong>'].freeze

  include ActiveModel::Model

  attr_accessor :query, :filters

  def initialize(attributes = nil)
    attributes[:query] = attributes[:query].gsub(/[^\w\-_@']/, ' ')
    attributes[:filters] ||= []

    super
  end

  def result_count
    groups_results.count + people_results.count
  end

  def include_groups?
    filters.include?('groups')
  end

  def include_people?
    filters.include?('people')
  end

  def groups_results
    return [] unless include_groups? && query.present?

    # TODO: This code replicates the behaviour of the previous search code, but searching groups should be moved to
    #       Elasticsearch one day
    query_words = query.split(/\W/).reject(&:blank?).map { |word| "%#{word}%" }
    @group_results ||= Group
                       .unscoped
                       .where(
                         'name ILIKE ALL(ARRAY[:words]) OR LOWER(acronym) = LOWER(:query)',
                         query: query,
                         words: query_words
                       )
                       .order(:ancestry_depth)
  end

  def people_results
    return [] unless include_people? && query.present?

    @people_results ||= Person.search(people_elasticsearch_query).records(includes: %i[memberships profile_photo])
  end

  private

  def people_elasticsearch_query # rubocop:disable Metrics/MethodLength
    {
      query: {
        bool: {
          should: [
            {
              match: {
                name: {
                  query: query,
                  boost: 6.0 # boost to prioritise exact matches over synonyms
                }
              }
            },
            {
              match: {
                name: {
                  query: query,
                  analyzer: 'name_synonyms_analyzer', # override the standard analyzer
                  boost: 4.0 # boost to prioritise synonym matches to 2nd rank
                }
              }
            },
            {
              match: {
                contact_email_or_email: query
              }
            },
            {
              multi_match: {
                fields: %w[
                  name^4
                  surname^12
                  role_and_group^6
                  phone_number_variations^5
                  languages^5
                  location^4
                  formatted_key_skills^4
                  formatted_learning_and_development^4
                ],
                fuzziness: 'AUTO',
                query: query,
                analyzer: 'standard'
              }
            }
          ],
          minimum_should_match: 1,
          boost: 1.0
        }
      },
      sort: {
        _score: { order: 'desc' },
        name: { order: 'asc' }
      },
      highlight: {
        pre_tags: ES_PRE_TAGS,
        post_tags: ES_POST_TAGS,
        number_of_fragments: 0, # always return entire field in highlight
        fields: {
          name: {},
          role_and_group: {},
          contact_email_or_email: {},
          languages: {},
          formatted_key_skills: {},
          formatted_learning_and_development: {}
        }
      },
      size: ES_MAX_RESULTS,
      min_score: ES_MIN_SCORE
    }
  end
end
