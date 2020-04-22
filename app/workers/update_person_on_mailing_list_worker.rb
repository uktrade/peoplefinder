# frozen_string_literal: true

class UpdatePersonOnMailingListWorker
  include Sidekiq::Worker

  def perform(email, previous_email, first_name, last_name, mailchimp_service = Mailchimp.new)
    # Only deactivate previous subscriber if there is a previous email and it has changed
    mailchimp_service.deactivate_subscriber(previous_email) if previous_email.present? && email != previous_email

    mailchimp_service.create_or_update_subscriber(
      email,
      merge_fields: { FNAME: first_name, LNAME: last_name }
    )
  end
end
