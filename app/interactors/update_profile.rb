# frozen_string_literal: true

class UpdateProfile
  include Interactor

  def call
    update_person
    check_person_is_valid
    save_person
    notify_updated_person_if_appropriate
  end

  private

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