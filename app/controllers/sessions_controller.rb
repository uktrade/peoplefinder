class SessionsController < ApplicationController
  include SessionPersonCreator
  include UserAgentHelper

  skip_before_action :ensure_user
  protect_from_forgery except: :create

  before_action :set_login_screen_flag

  def create
    oauth_login = OauthLogin.new(auth_hash)
    oauth_login.call(self)
  end

  def create_person
    @person = Person.new(person_params)
    @person.skip_must_have_team = true
    create_person_and_login @person
  end

  private

  def person_params
    params.require(:person).
      permit(
        :given_name,
        :surname,
        :email
      )
  end

  def set_login_screen_flag
    @login_screen = true
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
