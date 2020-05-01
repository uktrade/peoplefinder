# frozen_string_literal: true

module MailingLists
  class CreateOrUpdateSubscriberForPerson
    include Interactor

    def call
      create_or_update_subscriber
      set_subscriber_tags
    end

    private

    def create_or_update_subscriber
      mailing_list_service.create_or_update_subscriber(person.email, merge_fields: merge_fields)
    end

    def set_subscriber_tags
      mailing_list_service.set_subscriber_tags(person.email, tags: tags)
    end

    def person
      context.person
    end

    def merge_fields
      {
        FNAME: person.given_name,
        LNAME: person.surname
      }
    end

    def tags
      ['pf_imported'] + person.building.select(&:present?).map { |building| "pf_building_#{building}" }
    end

    def mailing_list_service
      context.mailing_list_service || MailingList.new
    end
  end
end
