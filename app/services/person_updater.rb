# frozen_string_literal: true

require 'forwardable'

class PersonUpdater
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person, :instigator

  def initialize(person:, instigator:, state_cookie:)
    raise NewRecordError, 'cannot update a new Person record' if person.new_record?

    @person = person
    @instigator = instigator
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

    UserUpdateMailer.updated_profile_email(
      person,
      instigator.try(:email)
    ).deliver_later
  end
end
