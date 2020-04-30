# frozen_string_literal: true

module MailingLists
  class CreateOrUpdateSubscriberForPersonWorker
    include Sidekiq::Worker

    def perform(person_id)
      person = Person.find_by(id: person_id)
      return unless person

      ::MailingLists::CreateOrUpdateSubscriberForPerson.call(person: person)
    end
  end
end
