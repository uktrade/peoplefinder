# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  include FeatureHelper

  before_action :ensure_user
  before_action :set_paper_trail_whodunnit

  layout 'peoplefinder'

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  breadcrumb 'home', :home

  def login_person(person)
    login_service = Login.new(session, person)
    login_service.login
    redirect_to desired_path(person)
  end

  private

  def user_for_paper_trail
    current_user.id if logged_in?
  end

  def info_for_paper_trail
    { ip_address: request.remote_ip, user_agent: request.user_agent }
  end

  def can_add_person_here?
    false
  end
  helper_method :can_add_person_here?

  def load_user
    Login.current_user(session)
  end

  def current_user
    @current_user ||= load_user
  rescue ActiveRecord::RecordNotFound
    session.destroy
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def ensure_user
    return true if logged_in?

    session[:desired_path] = request.fullpath
    redirect_to '/auth/ditsso_internal'
  end

  def desired_path(person)
    session.delete(:desired_path) || person_path(person, prompt: :profile)
  end

  def i18n_flash(type, *partial_key, **options)
    full_key = [
      :controllers, controller_path.tr('/', '.'), *partial_key
    ].join('.')
    flash[type] = I18n.t(full_key, options)
  end

  def warning(*partial_key, **options)
    i18n_flash :warning, partial_key, options
  end

  def notice(*partial_key, **options)
    i18n_flash :notice, partial_key, options
  end

  def error(*partial_key, **options)
    i18n_flash :error, partial_key, options
  end

  def user_not_authorized
    warning :unauthorised
    redirect_to home_path
  end

  def append_info_to_payload(payload)
    super

    payload[:sso_user_id] = current_user&.ditsso_user_id
    payload[:local_user_id] = current_user&.id
  end
end
