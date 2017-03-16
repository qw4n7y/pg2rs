# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170316074311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "imports_imports", force: :cascade do |t|
    t.string   "title"
    t.json     "s3",         default: "{}", null: false
    t.json     "postgres",   default: "{}", null: false
    t.json     "redshift",   default: "{}", null: false
    t.integer  "status",     default: 0,    null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "imports_migrations", force: :cascade do |t|
    t.integer  "import_id",  null: false
    t.text     "sql"
    t.text     "log"
    t.integer  "status",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_imports_migrations_on_import_id", using: :btree
  end

  create_table "imports_table_transfers", force: :cascade do |t|
    t.integer  "transfer_id", null: false
    t.integer  "table_id",    null: false
    t.integer  "status",      null: false
    t.datetime "finished_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["table_id"], name: "index_imports_table_transfers_on_table_id", using: :btree
    t.index ["transfer_id"], name: "index_imports_table_transfers_on_transfer_id", using: :btree
  end

  create_table "imports_tables", force: :cascade do |t|
    t.integer  "import_id"
    t.string   "name"
    t.integer  "strategy",        null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "init_sql_script"
    t.index ["import_id"], name: "index_imports_tables_on_import_id", using: :btree
  end

  create_table "imports_transfers", force: :cascade do |t|
    t.integer  "status",      null: false
    t.datetime "finished_at"
    t.integer  "import_id"
    t.text     "log"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["import_id"], name: "index_imports_transfers_on_import_id", using: :btree
  end

  create_table "users_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_users_on_reset_password_token", unique: true, using: :btree
  end

end
