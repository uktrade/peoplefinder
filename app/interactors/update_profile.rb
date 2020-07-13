# frozen_string_literal: true

class UpdateProfile
  include Interactor

  def call
    cache_email_before_update
    update_person
    check_person_is_valid
    save_person
    notify_updated_person_if_appropriate
    update_person_on_mailing_list
    touch_person_last_edited_or_confirmed_at
  end

  private

  def cache_email_before_update
    # Keep track of the user's email before any changes are saved for #update_person_on_mailing_list
    # (person.email_before_last_save is unreliable)
    @email_before_update = person.email
  end

  def update_person
    person.skip_must_not_have_disallowed_email_domain = true if instigator.role_administrator?

    person.assign_attributes(context.person_attributes)
  end

  def check_person_is_valid
    context.fail! unless person.valid?
  end

  def save_person
    person.save!
  end

  def notify_updated_person_if_appropriate
    return unless Rails.configuration.enable_external_integrations
    return unless person.notify_of_change?(instigator)

    notifier.updated_profile(
      person.email,
      recipient_name: person.name,
      instigator_name: instigator.name,
      profile_url: context.profile_url
    )
  end

  def update_person_on_mailing_list
    return unless Rails.configuration.enable_external_integrations

    MailingLists::DeactivateSubscriberWorker.perform_async(@email_before_update) if person.email != @email_before_update
    MailingLists::CreateOrUpdateSubscriberForPersonWorker.perform_async(person.id)
  end

  def touch_person_last_edited_or_confirmed_at
    # We don't mind not running validations on touching this attribute - this call should not fail
    person.touch(:last_edited_or_confirmed_at) # rubocop:disable Rails/SkipsModelValidations
  end

  def person
    context.person
  end

  def instigator
    context.instigator
  end

  def notifier
    context.notifier || GovukNotify.new
  end
end
