# frozen_string_literal: true

class LoginPerson
  include Interactor

  def call
    set_initial_person_attributes_from_sso if person.new_record?
    update_login_count_and_timestamp
    set_redirect_to_edit
    save_person
  end

  private

  def set_initial_person_attributes_from_sso
    person.skip_must_have_surname = true
    person.skip_must_have_team = true

    person.ditsso_user_id = sso_user_id
    person.email = sso_user_info['email']
    person.given_name = sso_user_info['first_name']&.titleize
    person.surname = sso_user_info['last_name']&.titleize
  end

  def update_login_count_and_timestamp
    person.login_count += 1
    person.last_login_at = Time.zone.now
  end

  def set_redirect_to_edit
    context.redirect_to_edit = person.new_record?
  end

  def save_person
    person.save!
  rescue ActiveRecord::ActiveRecordError => e
    # We don't want an error in saving the record (e.g. due to inconsistent state in DB) to fail creating a session
    # (but we do want to keep track of these to make sure we can discover root causes)
    Raven.capture_exception(e)
  end

  def person
    context.person ||= Person.find_or_initialize_by(ditsso_user_id: sso_user_id)
  end

  def sso_user_id
    context.oauth_hash['uid']
  end

  def sso_user_info
    context.oauth_hash['info']
  end
end
