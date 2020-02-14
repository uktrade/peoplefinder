# frozen_string_literal: true

class UpdateGroupMembersCompletionScoreJob < ApplicationJob
  # Typically this occurs if a record is deleted after the job is enqueued
  # but before it is executed (i.e. #perform called).
  rescue_from ActiveJob::DeserializationError, with: :error_handler

  queue_as :low_priority

  # update current groups and parent's score
  def perform(group)
    group.update_members_completion_score!
    UpdateGroupMembersCompletionScoreJob.perform_later(group.parent) if group.parent
  end

  private

  def error_handler(exception)
    if exception.is_a? ActiveJob::DeserializationError
      return exception.cause.is_a? ActiveRecord::RecordNotFound
    else
      return false
    end
  end
end
