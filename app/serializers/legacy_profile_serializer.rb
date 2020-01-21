# frozen_string_literal: true

class LegacyProfileSerializer
  # TODO: Used by the legacy Digital Workspace app to retrieve a profile, can be deleted
  #       once that application is fully decommissioned or changed to use v2 API

  def initialize(person)
    @person = person
  end

  # rubocop:disable Metrics/MethodLength
  def as_json(_options = {})
    {
      data: {
        id: person.id,
        type: 'people',
        attributes: {
          email: person.email,
          name: person.name,
          'given-name': person.given_name,
          surname: person.surname,
          'completion-score': person.completion_score,
          team: team
        },
        links: {
          profile: Rails.application.routes.url_helpers.person_url(person),
          'edit-profile': Rails.application.routes.url_helpers.edit_person_url(person),
          'profile-image-url': person.profile_image.try(:small).try(:url)
        }
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :person

  def team
    person.memberships[0].to_s
  end
end
