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

ActiveRecord::Schema.define(version: 2020_06_28_024942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "service"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_updated_at"
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
    t.text "metadata"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "edges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "source_id", null: false
    t.bigint "target_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_edges_on_user_id"
  end

  create_table "job_metrics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.bigint "connection_id", null: false
    t.integer "job_status"
    t.integer "run_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["connection_id"], name: "index_job_metrics_on_connection_id"
    t.index ["job_id"], name: "index_job_metrics_on_job_id"
    t.index ["user_id"], name: "index_job_metrics_on_user_id"
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
    t.text "message"
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
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vertices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "connection_id", null: false
    t.text "urn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["connection_id"], name: "index_vertices_on_connection_id"
    t.index ["user_id"], name: "index_vertices_on_user_id"
  end

  add_foreign_key "connections", "users"
  add_foreign_key "credential_options", "credentials"
  add_foreign_key "credentials", "connections"
  add_foreign_key "credentials", "users"
  add_foreign_key "edges", "users"
  add_foreign_key "job_metrics", "connections"
  add_foreign_key "job_metrics", "jobs"
  add_foreign_key "job_metrics", "users"
  add_foreign_key "jobs", "connections"
  add_foreign_key "jobs", "users"
  add_foreign_key "vertices", "connections"
  add_foreign_key "vertices", "users"
end
