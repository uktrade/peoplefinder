# frozen_string_literal: true

class UserUpdateMailer < ApplicationMailer
  include FeatureHelper
  extend Forwardable

  add_template_helper MailHelper

  def new_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: @person.email
  end

  def updated_profile_email(person, by_email = nil)
    @person = person
    @by_email = by_email
    @profile_url = profile_url(person)
    mail to: person.email
  end

  def deleted_profile_email(recipient_email, recipient_name, by_email = nil)
    @by_email = by_email
    @name = recipient_name
    mail to: recipient_email
  end

  private

  def profile_url(person)
    person_url(person)
  end
end
