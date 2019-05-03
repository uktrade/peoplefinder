# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :ensure_user
  before_action :set_login_screen_flag

  def create
    @person = person_from_oauth(auth_hash)

    if @person&.new_record?
      create_and_login_person(@person)
    elsif @person
      login_person(@person)
    end
  end

  private

  def set_login_screen_flag
    @login_screen = true
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def person_from_oauth(auth_hash)
    ditsso_user_id = auth_hash['uid']
    ditsso_email = EmailAddress.new(auth_hash['info']['email'])

    person = Person.find_or_initialize_by(ditsso_user_id: ditsso_user_id)

    if person.new_record?
      person.ditsso_user_id = ditsso_user_id
      person.email = ditsso_email
      person.given_name = auth_hash['info']['first_name'].try(:titleize)
      person.surname = auth_hash['info']['last_name'].try(:titleize)

      Rails.logger.info "[NewSession] Created new person by UUID: <#{ditsso_user_id}>, email: <#{ditsso_email}>"
    else
      Rails.logger.info "[NewSession] Found person with UUID: <#{ditsso_user_id}>, email: <#{ditsso_email}>"
    end

    person
  end

  def create_and_login_person(person)
    person.skip_must_have_surname = true
    person.skip_must_have_team = true

    PersonCreator.new(
      person: person,
      current_user: current_user,
      state_cookie: StateManagerCookie.new(cookies)
    ).create!

    warning :complete_profile
    session[:desired_path] = edit_person_path(person, page_title: 'Create profile')

    login_person(person)
  end
end
