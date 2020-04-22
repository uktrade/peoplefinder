# frozen_string_literal: true

class UpdatePersonOnMailingListWorker
  include Sidekiq::Worker

  def initialize(mailchimp_service: Mailchimp.new)
    @mailchimp_service = mailchimp_service
  end

  def perform(email, previous_email, first_name, last_name, tags)
    # Only deactivate previous subscriber if there is a previous email and it has changed
    begin
      @mailchimp_service.deactivate_subscriber(previous_email) if previous_email.present? && email != previous_email
    rescue Gibbon::MailChimpError
      # Don't fail if the previous email didn't exist
    end

    @mailchimp_service.create_or_update_subscriber(
      email,
      merge_fields: { FNAME: first_name, LNAME: last_name }
    )
    @mailchimp_service.set_subscriber_tags(email, tags: tags)
  end
end
