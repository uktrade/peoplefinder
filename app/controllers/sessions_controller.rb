class SessionsController < ApplicationController
  include UserAgentHelper

  skip_before_action :ensure_user
  before_action :set_login_screen_flag

  def create
    person = person_from_oauth(auth_hash)

    if person&.new_record?
      confirm_or_create(person)
    elsif person
      login_person(person)
    else
      render :failed
    end
  end

  private

  def person_from_oauth(auth_hash)
    ditsso_user_id = auth_hash['uid']
    email = EmailAddress.new(auth_hash['info']['email'])

    find_or_create_person(email, ditsso_user_id) do |new_person|
      new_person.ditsso_user_id = ditsso_user_id
      new_person.email = email
      new_person.internal_auth_key = email
      new_person.given_name = auth_hash['info']['first_name'].try(:titleize)
      new_person.surname = auth_hash['info']['last_name'].try(:titleize)
    end
  end

  def find_or_create_person(email, ditsso_user_id, &_on_create)
    person = find_person_by_ditsso_user_id(ditsso_user_id)
    person ||= find_person_by_internal_auth_key(email)
    person ||= Person.find_or_initialize_by(email: email.to_s)

    if person.new_record?
      yield(person)
      Rails.logger.info "[SessionPersonCreator] Created new person by UUID: <#{ditsso_user_id}>, email: <#{email}>"
    elsif person.internal_auth_key != email.to_s
      Rails.logger.info "[SessionPersonCreator] Found person by email: <#{email}> with "\
        "mismatching internal_auth_key: <#{person.internal_auth_key}>"
      person.update_column(:internal_auth_key, email.to_s) # rubocop:disable Rails/SkipsModelValidations
    end

    # TODO: Can be removed once every person has a ditsso_user_id
    unless person.new_record?
      person.update_column(:ditsso_user_id, ditsso_user_id) # rubocop:disable Rails/SkipsModelValidations
    end

    person
  end

  def find_person_by_ditsso_user_id(ditsso_user_id)
    return unless ditsso_user_id

    person = Person.find_by(ditsso_user_id: ditsso_user_id)
    Rails.logger.info "[SessionPersonCreator] Found person by ditsso_user_id: <#{ditsso_user_id}>" if person

    person
  end

  def find_person_by_internal_auth_key(email)
    person = Person.find_by(internal_auth_key: email.to_s)
    Rails.logger.info "[SessionPersonCreator] Found person by internal_auth_key: <#{email}>" if person

    person
  end

  def confirm_or_create(person)
    @person = person
    @person.skip_must_have_surname = true
    @person.skip_must_have_team = true
    if @person.valid?
      create_person_and_login @person
    else
      render :failed
    end
  end

  def create_person_and_login(person)
    person_creator = PersonCreator.new(person: person,
                                       current_user: current_user,
                                       state_cookie: StateManagerCookie.new(cookies))
    person_creator.create!
    warning :complete_profile
    session[:desired_path] = edit_person_path(@person, page_title: 'Create profile')
    login_person(@person)
  end

  def set_login_screen_flag
    @login_screen = true
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
