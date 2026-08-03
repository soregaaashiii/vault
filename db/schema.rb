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

ActiveRecord::Schema[8.1].define(version: 2026_06_16_000100) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "business_cards", force: :cascade do |t|
    t.datetime "archived_at"
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "label"
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_business_cards_on_archived_at"
    t.index ["contact_id"], name: "index_business_cards_on_contact_id"
    t.index ["created_by_id"], name: "index_business_cards_on_created_by_id"
    t.index ["organization_id"], name: "index_business_cards_on_organization_id"
  end

  create_table "companies", force: :cascade do |t|
    t.text "address"
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.text "description"
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["archived_at"], name: "index_companies_on_archived_at"
    t.index ["created_by_id"], name: "index_companies_on_created_by_id"
    t.index ["organization_id", "name"], name: "index_companies_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_companies_on_organization_id"
  end

  create_table "contact_notes", force: :cascade do |t|
    t.datetime "archived_at"
    t.text "body", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "visibility", default: "shared", null: false
    t.index ["archived_at"], name: "index_contact_notes_on_archived_at"
    t.index ["contact_id"], name: "index_contact_notes_on_contact_id"
    t.index ["organization_id", "visibility"], name: "index_contact_notes_on_organization_id_and_visibility"
    t.index ["organization_id"], name: "index_contact_notes_on_organization_id"
    t.index ["user_id"], name: "index_contact_notes_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "archived_at"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "email"
    t.text "memo"
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.string "phone"
    t.string "position"
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_contacts_on_archived_at"
    t.index ["company_id"], name: "index_contacts_on_company_id"
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["organization_id", "email"], name: "index_contacts_on_organization_id_and_email"
    t.index ["organization_id", "name"], name: "index_contacts_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_contacts_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_organizations_on_archived_at"
  end

  create_table "system_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_system_settings_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.integer "organization_id"
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_users_on_archived_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_cards", "contacts"
  add_foreign_key "business_cards", "organizations"
  add_foreign_key "business_cards", "users", column: "created_by_id"
  add_foreign_key "companies", "organizations"
  add_foreign_key "companies", "users", column: "created_by_id"
  add_foreign_key "contact_notes", "contacts"
  add_foreign_key "contact_notes", "organizations"
  add_foreign_key "contact_notes", "users"
  add_foreign_key "contacts", "companies"
  add_foreign_key "contacts", "organizations"
  add_foreign_key "contacts", "users", column: "created_by_id"
  add_foreign_key "users", "organizations"
end
