# frozen_string_literal: true

# Serializes a Person record for Data Workspace exports
class PersonDataWorkspaceSerializer
  PERSON_KEYS = %w[
    email skype_name
    works_monday works_tuesday works_wednesday works_thursday works_friday works_saturday works_sunday
    location_in_building city country
    language_fluent language_intermediate grade
    created_at last_edited_or_confirmed_at login_count last_login_at
  ].freeze

  def initialize(person)
    @person = person
  end

  def as_json(_options = {}) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity
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
        formatted_location: person.location,
        location_other_uk: person.other_uk,
        location_other_overseas: person.other_overseas,
        buildings: person.building.reject(&:empty?),
        formatted_buildings: person.formatted_buildings,
        roles: person.memberships.map do |m|
          { role: m.role, team_name: m.group.name, team_id: m.group.id, leader: m.leader? }
        end,
        formatted_roles: person.memberships.map { |m| "#{m.role}, #{m.group.name}" },
        key_skills: person.key_skills.reject(&:empty?),
        formatted_key_skills: person.formatted_key_skills,
        other_key_skills: person.other_key_skills,
        learning_and_development: person.learning_and_development.reject(&:empty?),
        other_learning_and_development: person.other_learning_and_development,
        formatted_learning_and_development: person.formatted_learning_and_development,
        networks: person.networks.reject(&:empty?),
        formatted_networks: person.formatted_networks,
        professions: person.professions.reject(&:empty?),
        formatted_professions: person.formatted_professions,
        additional_responsibilities: person.additional_responsibilities.reject(&:empty?),
        other_additional_responsibilities: person.other_additional_responsibilities,
        formatted_additional_responsibilities: person.formatted_additional_responsibilities,
        manager_people_finder_id: person.line_manager_id,
        completion_score: person.completion_score,
        profile_url: profile_url,
        country_name: person.country_name,
        formatted_grade: formatted_grade,
        is_stale: person.stale?
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

  def formatted_grade
    return nil if person.grade.blank?

    I18n.translate(person.grade, scope: 'people.grade_names', default: '')
  end
end
