# frozen_string_literal: true

class UpdatePersonOnMailingList
  include Interactor

  def call
    return unless Rails.configuration.mailing_list_integration_enabled

    UpdatePersonOnMailingListWorker.perform_async(
      person.email,
      context.previous_email,
      person.given_name,
      person.surname,
      mailchimp_tags
    )
  end

  private

  def person
    context.person
  end

  def mailchimp_tags
    ['pf_imported'] + person.building.select(&:present?).map { |building| "pf_building_#{building}" }
  end
end
