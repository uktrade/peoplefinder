# frozen_string_literal: true

class RemovePersonFromMailingListWorker
  include Sidekiq::Worker

  def initialize(mailchimp_service: Mailchimp.new)
    @mailchimp_service = mailchimp_service
  end

  def perform(email)
    @mailchimp_service.deactivate_subscriber(email)
  end
end
