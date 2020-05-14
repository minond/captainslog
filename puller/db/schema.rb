# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_14_234743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_connections_on_user_id"
  end

  create_table "credential_options", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.string "label"
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credential_id"], name: "index_credential_options_on_credential_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "connection_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["connection_id"], name: "index_credentials_on_connection_id"
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status"
    t.string "kind"
    t.text "logs"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "connection_id", null: false
    t.index ["connection_id"], name: "index_jobs_on_connection_id"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "encrypted_password"
    t.text "salt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "connections", "users"
  add_foreign_key "credential_options", "credentials"
  add_foreign_key "credentials", "connections"
  add_foreign_key "credentials", "users"
  add_foreign_key "jobs", "connections"
  add_foreign_key "jobs", "users"
end
