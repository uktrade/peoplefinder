class InitSchema < ActiveRecord::Migration[6.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "delayed_jobs", id: :serial do |t|
      t.integer "priority", default: 0, null: false
      t.integer "attempts", default: 0, null: false
      t.text "handler", null: false
      t.text "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string "locked_by"
      t.string "queue"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    end
    create_table "groups", id: :serial do |t|
      t.text "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "slug"
      t.text "description"
      t.text "ancestry"
      t.integer "ancestry_depth", default: 0, null: false
      t.text "acronym"
      t.datetime "description_reminder_email_at"
      t.integer "members_completion_score"
      t.index ["ancestry"], name: "index_groups_on_ancestry"
      t.index ["slug"], name: "index_groups_on_slug"
    end
    create_table "memberships", id: :serial do |t|
      t.integer "group_id", null: false
      t.integer "person_id", null: false
      t.text "role"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "leader", default: false
      t.boolean "subscribed", default: true, null: false
      t.index ["group_id"], name: "index_memberships_on_group_id"
      t.index ["person_id"], name: "index_memberships_on_person_id"
    end
    create_table "people", id: :serial do |t|
      t.text "given_name"
      t.text "surname"
      t.text "email"
      t.text "primary_phone_number"
      t.text "secondary_phone_number"
      t.text "location_in_building"
      t.text "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "works_monday", default: true
      t.boolean "works_tuesday", default: true
      t.boolean "works_wednesday", default: true
      t.boolean "works_thursday", default: true
      t.boolean "works_friday", default: true
      t.string "slug"
      t.boolean "works_saturday", default: false
      t.boolean "works_sunday", default: false
      t.integer "login_count", default: 0, null: false
      t.datetime "last_login_at"
      t.boolean "super_admin", default: false
      t.text "city"
      t.text "secondary_email"
      t.integer "profile_photo_id"
      t.datetime "last_reminder_email_at"
      t.string "current_project"
      t.text "pager_number"
      t.text "primary_phone_country_code"
      t.string "building", default: [], array: true
      t.string "country"
      t.string "skype_name"
      t.string "key_skills", default: [], array: true
      t.text "language_fluent"
      t.text "language_intermediate"
      t.text "grade"
      t.text "previous_positions"
      t.string "learning_and_development", default: [], array: true
      t.string "networks", default: [], array: true
      t.string "additional_responsibilities", default: [], array: true
      t.text "other_uk"
      t.text "other_overseas"
      t.string "internal_auth_key"
      t.string "other_key_skills"
      t.string "other_learning_and_development"
      t.string "other_additional_responsibilities"
      t.string "professions", default: [], array: true
      t.string "other_professions"
      t.text "secondary_phone_country_code"
      t.string "ditsso_user_id"
      t.string "pronouns"
      t.index ["slug"], name: "index_people_on_slug", unique: true
    end
    create_table "profile_photos", id: :serial do |t|
      t.string "image"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "queued_notifications", id: :serial do |t|
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
    create_table "reports", id: :serial do |t|
      t.text "content"
      t.string "name"
      t.string "extension"
      t.string "mime_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "sessions", id: :serial do |t|
      t.string "session_id", null: false
      t.text "data"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
      t.index ["updated_at"], name: "index_sessions_on_updated_at"
    end
    create_table "versions", id: :serial do |t|
      t.text "item_type", null: false
      t.integer "item_id", null: false
      t.text "event", null: false
      t.text "whodunnit"
      t.text "object"
      t.datetime "created_at"
      t.text "object_changes"
      t.string "ip_address"
      t.string "user_agent"
      t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    end
    add_foreign_key "memberships", "groups"
    add_foreign_key "memberships", "people"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
