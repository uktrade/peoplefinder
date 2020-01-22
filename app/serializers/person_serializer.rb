# frozen_string_literal: true

class PersonSerializer
  def initialize(person)
    @person = person
  end

  # rubocop:disable Metrics/MethodLength
  def as_json(_options = {})
    {
      id: person.id,
      ditsso_user_id: person.ditsso_user_id,
      name: person.name,
      email: person.email,
      phone_number: phone_number,
      completion_score: person.completion_score,

      # Give names more sensible names (sic) than the internal People Finder nomenclature
      first_name: person.given_name,
      last_name: person.surname,

      links: {
        profile_url: profile_url,
        edit_profile_url: edit_profile_url,
        profile_image_small: profile_image_small,
        profile_image_medium: profile_image_medium
      },

      roles: person.memberships.map do |membership|
        { role: membership.role, group: membership.group.name }
      end
    }
  end
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :person

  def phone_number
    ApplicationController.helpers.phone_number_with_country_code(
      person.primary_phone_country,
      person.primary_phone_number
    )
  end

  def profile_url
    Rails.application.routes.url_helpers.person_url(person)
  end

  def edit_profile_url
    Rails.application.routes.url_helpers.edit_person_url(person)
  end

  def profile_image_small
    person.profile_image.try(:small).try(:url)
  end

  def profile_image_medium
    person.profile_image.try(:medium).try(:url)
  end
end
