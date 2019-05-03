# frozen_string_literal: true

class UpdateGroupMembersCompletionScoreJob < ApplicationJob
  # Typically this occurs if a record is deleted after the job is enqueued
  # but before it is executed (i.e. #perform called).
  rescue_from ActiveJob::DeserializationError, with: :error_handler

  queue_as :low_priority

  around_enqueue do |job, block|
    block.call unless enqueued? job.arguments.first
  end

  # update current groups and parent's score
  def perform(group)
    group.update_members_completion_score!
    UpdateGroupMembersCompletionScoreJob.perform_later(group.parent) if group.parent
  end

  private

  def enqueued?(group)
    count = Delayed::Job
            .where("substring(handler from 'job_class: #{self.class}') IS NOT NULL")
            .where("substring(handler from 'gid://peoplefinder/Group/#{group.id}.*') IS NOT NULL")
            .count
    count > 0
  end

  def error_handler(exception)
    Rails.logger.warn "#{self.class} encountered #{exception.class}: #{exception.message}"
    if exception.is_a? ActiveJob::DeserializationError
      return exception.cause.is_a? ActiveRecord::RecordNotFound
    else
      return false
    end
  end
end
