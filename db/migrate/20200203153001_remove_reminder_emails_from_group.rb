class RemoveReminderEmailsFromGroup < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :description_reminder_email_at
  end
end
