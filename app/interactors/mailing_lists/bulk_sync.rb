# frozen_string_literal: true

# Bulk update Mailchimp with current People Finder data
# We update Mailchimp at the relevant points in the `Person` model lifecycle, but this serves
# as another line of defence against sync issues.
module MailingLists
  class BulkSync
    include Interactor

    def call
      return unless Rails.configuration.enable_external_integrations

      load_existing_subscribers
      delete_subscribers_missing_locally
      create_or_update_subscriber_for_all_people
    end

    private

    def load_existing_subscribers
      @existing_subscriber_emails = mailing_list_service.all_subscribers
    end

    def delete_subscribers_missing_locally
      local_user_emails = Person.pluck(:email)
      subscribers_to_deactivate = @existing_subscriber_emails - local_user_emails

      subscribers_to_deactivate.each do |email|
        DeactivateSubscriber.call(email: email)
      rescue StandardError => e
        Raven.capture_exception(e)
      end
    end

    def create_or_update_subscriber_for_all_people
      Person.find_each do |person|
        CreateOrUpdateSubscriberForPerson.call(person: person)
      rescue StandardError => e
        Raven.capture_exception(e)
      end
    end

    def mailing_list_service
      context.mailing_list_service || MailingList.new
    end
  end
end
