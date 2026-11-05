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

ActiveRecord::Schema[8.1].define(version: 2026_11_05_025850) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "room_images", force: :cascade do |t|
    t.integer "room_id"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "state"
    t.integer "price"
    t.string "description"
    t.string "home_type"
    t.string "room_type"
    t.integer "total_occupancy"
    t.integer "total_bedrooms"
    t.integer "total_bathrooms"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token_digest"
    t.datetime "reset_password_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "last_login_at"
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["reset_password_token_digest"], name: "index_users_on_reset_password_token_digest"
    t.index ["role"], name: "index_users_on_role"
  end
end
