# frozen_string_literal: true

module MailingLists
  class DeactivateSubscriber
    include Interactor

    def call
      mailing_list_service.deactivate_subscriber(context.email)
    end

    private

    def mailing_list_service
      context.mailing_list_service || MailingList.new
    end
  end
end
