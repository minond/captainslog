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

ActiveRecord::Schema.define(version: 2020_04_09_030736) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.integer "grouping", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug", null: false
    t.index ["user_id", "slug"], name: "books_user_id_slug_unique", unique: true
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "datetime", null: false
    t.index ["book_id"], name: "index_collections_on_book_id"
  end

  create_table "connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id"
    t.string "data_source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_update_attempted_at"
    t.bigint "last_update_job_id"
    t.index ["book_id"], name: "index_connections_on_book_id"
    t.index ["user_id"], name: "index_connections_on_user_id"
  end

  create_table "credential_options", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.string "label", null: false
    t.text "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credential_id"], name: "index_credential_options_on_credential_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "connection_id", null: false
    t.index ["connection_id"], name: "index_credentials_on_connection_id"
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.text "metadata"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "collection_id", null: false
    t.text "original_text"
    t.text "processed_text"
    t.jsonb "processed_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "data"
    t.bigint "user_id", null: false
    t.datetime "processed_at"
    t.datetime "date"
    t.text "digest"
    t.bigint "connection_id"
    t.index ["book_id"], name: "index_entries_on_book_id"
    t.index ["collection_id"], name: "index_entries_on_collection_id"
    t.index ["connection_id"], name: "index_entries_on_connection_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "extractors", force: :cascade do |t|
    t.string "label", null: false
    t.string "match", null: false
    t.bigint "book_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.integer "data_type"
    t.index ["book_id"], name: "index_extractors_on_book_id"
    t.index ["user_id"], name: "index_extractors_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status"
    t.integer "kind"
    t.text "args"
    t.text "logs"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "report_outputs", force: :cascade do |t|
    t.string "label", null: false
    t.string "width"
    t.string "height"
    t.integer "kind", null: false
    t.text "query"
    t.bigint "report_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order"
    t.index ["report_id"], name: "index_report_outputs_on_report_id"
  end

  create_table "report_variables", force: :cascade do |t|
    t.string "label", null: false
    t.string "default_value"
    t.text "query"
    t.bigint "report_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["report_id"], name: "index_report_variables_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "label", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "shorthands", force: :cascade do |t|
    t.integer "priority", null: false
    t.string "expansion", null: false
    t.string "match"
    t.string "text"
    t.bigint "book_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_shorthands_on_book_id"
    t.index ["user_id"], name: "index_shorthands_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "timezone"
    t.string "name"
    t.text "salt"
    t.string "homepage"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "books", "users"
  add_foreign_key "collections", "books"
  add_foreign_key "connections", "books"
  add_foreign_key "connections", "users"
  add_foreign_key "credential_options", "credentials"
  add_foreign_key "credentials", "connections"
  add_foreign_key "credentials", "users"
  add_foreign_key "entries", "books"
  add_foreign_key "entries", "collections"
  add_foreign_key "entries", "connections"
  add_foreign_key "entries", "users"
  add_foreign_key "extractors", "books"
  add_foreign_key "extractors", "users"
  add_foreign_key "jobs", "users"
  add_foreign_key "report_outputs", "reports"
  add_foreign_key "report_variables", "reports"
  add_foreign_key "reports", "users"
  add_foreign_key "shorthands", "books"
  add_foreign_key "shorthands", "users"
end
