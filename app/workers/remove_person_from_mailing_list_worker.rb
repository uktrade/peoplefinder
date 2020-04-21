# frozen_string_literal: true

class RemovePersonFromMailingListWorker
  include Sidekiq::Worker

  def perform(email, mailchimp_service = Mailchimp.new)
    mailchimp_service.deactivate_subscriber(email)
  end
end
