class DeleteQueuedNotifications < ActiveRecord::Migration[6.0]
  def change
    drop_table :queued_notifications do |t|
      t.string "email_template"
      t.string "session_id"
      t.integer "person_id"
      t.integer "current_user_id"
      t.text "changes_json"
      t.boolean "edit_finalised", default: false
      t.datetime "processing_started_at"
      t.boolean "sent", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
