# frozen_string_literal: true

require 'forwardable'

class PersonCreator
  extend Forwardable

  def_delegators :person, :valid?

  attr_reader :person, :current_user, :session_id
  def initialize(person:, current_user:, state_cookie:, session_id: nil)
    @person = person
    @current_user = current_user
    @state_cookie = state_cookie
    @session_id = session_id
  end

  def create!
    person.save!
  end

  def edit_finalised?
    @state_cookie.save_profile?
  end

  def flash_message
    :profile_created
  end
end
