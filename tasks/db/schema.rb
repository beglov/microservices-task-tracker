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

ActiveRecord::Schema[7.0].define(version: 2022_08_13_120007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "account_roles", ["admin", "worker", "manager"]
  create_enum "task_statuses", ["open", "close"]

  create_table "accounts", force: :cascade do |t|
    t.uuid "public_id", null: false
    t.string "full_name"
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "worker", null: false, enum_type: "account_roles"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "open", null: false, enum_type: "task_statuses"
    t.index ["account_id"], name: "index_tasks_on_account_id"
  end

  add_foreign_key "tasks", "accounts"
end
