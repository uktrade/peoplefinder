# frozen_string_literal: true

class SendNotificationsJob < ApplicationJob
  queue_as :send_notifications

  def perform
    notify_people!
  end

  def max_attempts
    3
  end

  def max_run_time
    10.minutes
  end

  def destroy_failed_jobs?
    false
  end

  def notify_people!
    NotificationSender.new.send!
  end
end
