# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_21_103046) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.text "description"
    t.text "ancestry"
    t.integer "ancestry_depth", default: 0, null: false
    t.text "acronym"
    t.integer "members_completion_score"
    t.index ["ancestry"], name: "index_groups_on_ancestry"
    t.index ["slug"], name: "index_groups_on_slug"
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "person_id", null: false
    t.text "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "leader", default: false
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["person_id"], name: "index_memberships_on_person_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.text "given_name"
    t.text "surname"
    t.text "email"
    t.text "primary_phone_number"
    t.text "secondary_phone_number"
    t.text "location_in_building"
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
    t.boolean "role_administrator", default: false
    t.text "city"
    t.integer "profile_photo_id"
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
    t.string "other_key_skills"
    t.string "other_learning_and_development"
    t.string "other_additional_responsibilities"
    t.string "professions", default: [], array: true
    t.string "other_professions"
    t.string "ditsso_user_id"
    t.string "pronouns"
    t.integer "line_manager_id"
    t.boolean "line_manager_not_required", default: false
    t.boolean "role_people_editor", default: false
    t.boolean "role_groups_editor", default: false
    t.datetime "last_edited_or_confirmed_at"
    t.string "contact_email"
    t.index ["slug"], name: "index_people_on_slug", unique: true
  end

  create_table "profile_photos", id: :serial, force: :cascade do |t|
    t.string "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "name"
    t.string "extension"
    t.string "mime_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", id: :serial, force: :cascade do |t|
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
