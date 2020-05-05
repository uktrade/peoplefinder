# frozen_string_literal: true

module MailingLists
  class BulkSyncWorker
    include Sidekiq::Worker

    def perform
      BulkSync.call
    end
  end
end
