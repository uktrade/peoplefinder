# frozen_string_literal: true

class LoginPerson
  include Interactor

  def call
    set_initial_person_attributes_from_sso if person.new_record?
    update_login_count_and_timestamp if person.persisted?
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
    person.login_count = 1
    person.last_login_at = DateTime.current
  end

  def update_login_count_and_timestamp
    # Some user accounts fail validation because e.g. they backed out of the first login flow and never set a team
    # We don't want this to stop us setting login count and last login date
    # rubocop:disable Rails/SkipsModelValidations
    person.touch(:last_login_at)
    person.increment!(:login_count)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def set_redirect_to_edit
    context.redirect_to_edit = person.new_record? || person.invalid?
  end

  def save_person
    person.save
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
