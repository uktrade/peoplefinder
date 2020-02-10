# frozen_string_literal: true

require 'forwardable'

class PersonUpdater
  extend Forwardable

  attr_reader :person, :instigator

  def initialize(person:, instigator:, profile_url:, state_cookie:)
    raise 'Cannot update a new Person record' if person.new_record?

    @person = person
    @instigator = instigator
    @profile_url = profile_url
    @state_cookie = state_cookie
  end

  def update!
    person.save!
    send_notification
  end

  def flash_message
    :profile_updated
  end

  def edit_finalised?
    @state_cookie.save_profile?
  end

  private

  def send_notification
    return unless person.notify_of_change?(instigator)

    GovukNotify.new.updated_profile(
      person.email,
      recipient_name: person.name,
      instigator_name: instigator.name,
      profile_url: @profile_url
    )
  end
end
