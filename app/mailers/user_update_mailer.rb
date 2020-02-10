# frozen_string_literal: true

class UserUpdateMailer < ApplicationMailer
  include FeatureHelper
  extend Forwardable

  add_template_helper MailHelper

  def updated_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: person.email
  end

  private

  def profile_url(person)
    person_url(person)
  end
end
