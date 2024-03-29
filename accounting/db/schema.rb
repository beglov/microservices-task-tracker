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

ActiveRecord::Schema[7.0].define(version: 2022_10_06_200226) do
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
    t.decimal "balance", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "worker", null: false, enum_type: "account_roles"
    t.string "encrypted_password", default: "", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "task_id"
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.string "description"
    t.decimal "credit", default: "0.0", null: false
    t.decimal "debit", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_payment_transactions_on_account_id"
    t.index ["task_id"], name: "index_payment_transactions_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.uuid "public_id", null: false
    t.string "title"
    t.string "jira_id"
    t.text "description"
    t.decimal "fee_price", default: "0.0", null: false
    t.decimal "complete_price", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "open", null: false, enum_type: "task_statuses"
    t.index ["account_id"], name: "index_tasks_on_account_id"
  end

  add_foreign_key "payment_transactions", "accounts"
  add_foreign_key "payment_transactions", "tasks"
  add_foreign_key "tasks", "accounts"
end
