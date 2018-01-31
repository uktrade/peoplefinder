class SessionsController < ApplicationController
  include SessionPersonCreator
  include UserAgentHelper

  skip_before_action :ensure_user
  protect_from_forgery except: :create

  before_action :set_login_screen_flag

  def create
    oauth_login = OauthLogin.new(auth_hash)
    oauth_login.call(self)
    assign_ditsso_internal_token
  end

  def new
    @unauthorised_login = session.delete(:unauthorised_login)
    redirect_to unsupported_browser_new_sessions_path if unsupported_browser?
  end

  def destroy
    Login.new(session, @current_user).logout
    redirect_to '/'
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

  def assign_ditsso_internal_token
    if auth_hash['credentials']
      session[:ditsso_internal_token] = auth_hash['credentials']['token']
    end
  end
end
