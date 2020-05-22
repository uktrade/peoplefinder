# frozen_string_literal: true

# Serializes minimal profile information used to render a profile header across the Digital Workspace suite
class PersonProfileSerializer
  def initialize(person)
    @person = person
  end

  def as_json(_options = {})
    {
      first_name: person.given_name,
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
    person.profile_image.try(:small).try(:url)
  end
end
