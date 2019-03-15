module SessionPersonCreator
  extend ActiveSupport::Concern

  included do
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

    def render_or_redirect_login person
      if person&.new_record?
        confirm_or_create person
      elsif person
        login_person(person)
      else
        render :failed
      end
    end

    private

    def find_or_create_person(email, ditsso_user_id, &_on_create)
      Rails.logger.info "find_or_create_person - email: <#{email}>, ditsso_user_id: <#{ditsso_user_id}>"

      person = (ditsso_user_id && Person.find_by(ditsso_user_id: ditsso_user_id))
      person ||= Person.find_by(internal_auth_key: email.to_s)
      person ||= Person.find_or_initialize_by(email: email.to_s)

      if person.new_record?
        yield(person)
      elsif person.internal_auth_key != email.to_s
        person.update_column(:internal_auth_key, email.to_s) # rubocop:disable Rails/SkipsModelValidations
      end

      # TODO: Can be removed once every person has a ditsso_user_id
      unless person.new_record?
        person.update_column(:ditsso_user_id, ditsso_user_id) # rubocop:disable Rails/SkipsModelValidations
      end

      person
    end

    def confirm_or_create person
      @person = person
      @person.skip_must_have_surname = true
      @person.skip_must_have_team = true
      if @person.valid?
        if namesakes?
          warning :person_confirm
          render 'sessions/person_confirm'
        else
          create_person_and_login @person
        end
      else
        render :failed
      end
    end

    def create_person_and_login person
      person_creator = PersonCreator.new(person: person,
                                         current_user: current_user,
                                         state_cookie: StateManagerCookie.new(cookies))
      person_creator.create!
      warning :complete_profile
      session[:desired_path] = edit_person_path(@person, page_title: 'Create profile')
      login_person(@person)
    end

    def namesakes?
      return false if params['commit'] == 'Continue, it is not one of these'
      @people = Person.namesakes(@person)
      @people.present?
    end
  end

end
