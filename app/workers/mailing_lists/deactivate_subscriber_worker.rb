# frozen_string_literal: true

module MailingLists
  class DeactivateSubscriberWorker
    include Sidekiq::Worker

    def perform(email)
      ::MailingLists::DeactivateSubscriber.call(email: email)
    end
  end
end
