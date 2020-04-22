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
    person.assign_attributes(context.person_attributes)
  end

  def check_person_is_valid
    context.fail! unless person.valid?
  end

  def save_person
    person.save!
  end

  def notify_updated_person_if_appropriate
    return unless person.notify_of_change?(instigator)

    notifier.updated_profile(
      person.email,
      recipient_name: person.name,
      instigator_name: instigator.name,
      profile_url: context.profile_url
    )
  end

  def update_person_on_mailing_list
    return unless Rails.configuration.mailing_list_integration_enabled

    UpdatePersonOnMailingListWorker.perform_async(
      person.email,
      @email_before_update,
      person.given_name,
      person.surname,
      mailchimp_tags
    )
  end

  def touch_person_last_edited_or_confirmed_at
    # We don't mind not running validations on touching this attribute - this call should not fail
    person.touch(:last_edited_or_confirmed_at) # rubocop:disable Rails/SkipsModelValidations
  end

  def mailchimp_tags
    # TODO: This is an MVP and needs to move into a more appropriate place
    ['pf_imported'] + person.building.select(&:present?).map { |building| "pf_building_#{building}" }
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
