class ApplicationController < ActionController::Base
  SESSION_KEY = 'current_user_id'

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :ensure_user, :set_paper_trail_whodunnit

  breadcrumb 'home', :home

  private

  def user_for_paper_trail
    current_user.id if logged_in?
  end

  def info_for_paper_trail
    { ip_address: request.remote_ip, user_agent: request.user_agent }
  end

  def current_user
    return nil if session[SESSION_KEY].blank?

    @current_user ||= Person.find(session[SESSION_KEY])
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
    #redirect_to '/auth/ditsso_internal'

    logger.warn("POST...")
    logger.warn(request.base_url + '/auth/ditsso_internal')

    HTTParty.post(request.base_url + '/auth/ditsso_internal')
  end

  def i18n_flash(type, *partial_key, **options)
    full_key = [
      :controllers, controller_path.tr('/', '.'), *partial_key
    ].join('.')
    flash[type] = I18n.t(full_key, **options)
  end

  def warning(*partial_key, **options)
    i18n_flash :warning, partial_key, **options
  end

  def notice(*partial_key, **options)
    i18n_flash :notice, partial_key, **options
  end

  def error(*partial_key, **options)
    i18n_flash :error, partial_key, **options
  end

  def user_not_authorized
    warning :unauthorised
    redirect_to home_path
  end

  def append_info_to_payload(payload)
    super
    return if current_user.blank?

    payload[:sso_user_id] = current_user.ditsso_user_id
    payload[:local_user_id] = current_user.id
  end
end
