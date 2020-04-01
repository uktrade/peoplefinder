# frozen_string_literal: true

class RemovePerson
  include Interactor

  def call
    delete_person
    send_notification_to_deleted_person
  end

  private

  def delete_person
    person.destroy!
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
