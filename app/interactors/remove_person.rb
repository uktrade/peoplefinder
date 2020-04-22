# frozen_string_literal: true

class RemovePerson
  include Interactor

  def call
    delete_person
    remove_person_from_mailing_list
    send_notification_to_deleted_person
  end

  private

  def delete_person
    person.destroy!
  end

  def remove_person_from_mailing_list
    return unless Rails.configuration.mailing_list_integration_enabled

    RemovePersonFromMailingListWorker.perform_async(person.email)
  end

  def send_notification_to_deleted_person
    notifier.deleted_profile(person.email, recipient_name: person.name)
  end

  def person
    context.person
  end

  def notifier
    context.notifier || GovukNotify.new
  end
end
