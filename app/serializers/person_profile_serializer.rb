# frozen_string_literal: true

# Serializes minimal profile information used to render a profile header across the Digital Workspace suite
class PersonProfileSerializer
  def initialize(person)
    @person = person
  end

  def as_json(_options = {})
    {
      name: person.name,
      first_name: person.given_name,
      email: person.email,
      completion_score: person.completion_score,
      profile_url: profile_url,
      profile_image_url: profile_image_small_url
    }
  end

  private

  attr_reader :person

  def profile_url
    Rails.application.routes.url_helpers.person_url(person)
  end

  def profile_image_small_url
    url_or_path = person.profile_image.try(:small).try(:url)

    # FIXME: Hotfix for Carrierwave default image suddenly behaving differently and not returning a URL
    return nil unless url_or_path&.start_with?('http')

    url_or_path
  end
end
