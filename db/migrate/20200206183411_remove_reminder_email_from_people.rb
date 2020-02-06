class RemoveReminderEmailFromPeople < ActiveRecord::Migration[6.0]
  def change
    remove_column :people, :last_reminder_email_at
  end
end
