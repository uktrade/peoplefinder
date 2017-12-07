class TokenCheckerController < ApplicationController
  skip_before_action :ensure_user

  def show
    if AuthUserIntrospector.valid?(session[:ditsso_internal_token], current_user)
      render status: :ok, json: { active: true }
    else
      Login.new(session, current_user).logout
      session[:ditsso_internal_token] = nil
      render status: 401, json: { active: false, redirect_url: "#{ENV['HOME_PAGE_URL']}/logout" }
    end
  end
end
