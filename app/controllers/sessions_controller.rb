# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :ensure_user

  def create
    result = LoginPerson.call(oauth_hash: oauth_hash)
    session[SESSION_KEY] = result.person.id

    if result.redirect_to_edit
      warning :complete_profile
      redirect_to edit_person_path(result.person, page_title: 'Create profile')
    else
      redirect_to desired_path_or_profile(result.person)
    end
  end

  private

  def oauth_hash
    request.env['omniauth.auth']
  end

  def desired_path_or_profile(person)
    session.delete(:desired_path) || person_path(person)
  end
end
