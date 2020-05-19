# frozen_string_literal: true

# Serializes a Person record for Data Workspace exports
class PersonDataWorkspaceSerializer
  PERSON_KEYS = %w[
    email skype_name
    works_monday works_tuesday works_wednesday works_thursday works_friday works_saturday works_sunday
    location_in_building city country
    language_fluent language_intermediate grade
    created_at last_edited_or_confirmed_at
  ].freeze

  def initialize(person)
    @person = person
  end

  def as_json(_options = {}) # rubocop:disable Metrics/MethodLength
    person
      .as_json
      .slice(*PERSON_KEYS)
      .merge(
        people_finder_id: person.id,
        staff_sso_id: person.ditsso_user_id,
        full_name: person.name,
        first_name: person.given_name,
        last_name: person.surname,
        primary_phone_number: primary_phone_number,
        secondary_phone_number: secondary_phone_number,
        location_other_uk: person.other_uk,
        location_other_overseas: person.other_overseas,
        place_of_work: person.formatted_buildings,
        roles: person.memberships.map { |membership| "#{membership.role}; #{membership.group.name}" },
        key_skills: person.formatted_key_skills,
        learning_and_development: person.formatted_learning_and_development,
        networks: person.formatted_networks,
        professions: person.formatted_professions,
        additional_responsibilities: person.formatted_additional_responsibilities,
        manager_people_finder_id: person.line_manager_id,
        completion_score: person.completion_score,
        profile_url: profile_url
      )
      .stringify_keys
  end

  private

  attr_reader :person

  def primary_phone_number
    ApplicationController.helpers.phone_number_with_country_code(
      person.primary_phone_country,
      person.primary_phone_number
    )
  end

  def secondary_phone_number
    ApplicationController.helpers.phone_number_with_country_code(
      person.secondary_phone_country,
      person.secondary_phone_number
    )
  end

  def profile_url
    Rails.application.routes.url_helpers.person_url(person)
  end
end
