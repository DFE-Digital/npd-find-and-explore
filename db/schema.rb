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

ActiveRecord::Schema.define(version: 2019_10_16_121906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "unique_session_id"
    t.datetime "deactivated_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.integer "position"
    t.index ["ancestry", "position"], name: "index_categories_on_ancestry_and_position"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
  end

  create_table "category_translations", force: :cascade do |t|
    t.uuid "category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.index ["category_id"], name: "index_category_translations_on_category_id"
    t.index ["locale"], name: "index_category_translations_on_locale"
  end

  create_table "concept_translations", force: :cascade do |t|
    t.uuid "concept_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.index ["concept_id"], name: "index_concept_translations_on_concept_id"
    t.index ["locale"], name: "index_concept_translations_on_locale"
  end

  create_table "concepts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_concepts_on_category_id"
  end

  create_table "data_elements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "source_table_name"
    t.string "source_attribute_name"
    t.json "additional_attributes"
    t.integer "identifiability"
    t.string "sensitivity", limit: 1
    t.uuid "concept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_old_attribute_name", array: true
    t.integer "academic_year_collected_from"
    t.integer "academic_year_collected_to"
    t.string "collection_terms", array: true
    t.text "values"
    t.text "description_en"
    t.text "description_cy"
    t.string "npd_alias", null: false
    t.string "data_type"
    t.string "educational_phase", array: true
    t.string "tab_name"
    t.string "standard_extract"
    t.boolean "is_cla", default: false
    t.index ["concept_id"], name: "index_data_elements_on_concept_id"
    t.index ["npd_alias"], name: "index_data_elements_on_npd_alias", unique: true
  end

  create_table "data_table_rows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "data_table_upload_id"
    t.uuid "concept_id"
    t.string "npd_alias"
    t.string "source_table_name"
    t.string "source_attribute_name"
    t.string "source_old_attribute_name", array: true
    t.json "additional_attributes"
    t.integer "identifiability"
    t.string "sensitivity", limit: 1
    t.integer "academic_year_collected_from"
    t.integer "academic_year_collected_to"
    t.string "collection_terms", array: true
    t.string "educational_phase", array: true
    t.string "data_type"
    t.text "values"
    t.text "description_en"
    t.text "description_cy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tab_name"
    t.string "standard_extract"
    t.boolean "is_cla", default: false
    t.index ["concept_id"], name: "index_data_table_rows_on_concept_id"
    t.index ["data_table_upload_id", "npd_alias"], name: "index_data_table_rows_on_data_table_upload_id_and_npd_alias", unique: true
    t.index ["data_table_upload_id"], name: "index_data_table_rows_on_data_table_upload_id"
  end

  create_table "data_table_tabs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.uuid "data_table_upload_id"
    t.string "tab_name"
    t.json "headers"
    t.json "process_errors"
    t.json "process_warnings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_table_upload_id"], name: "index_data_table_tabs_on_data_table_upload_id"
  end

  create_table "data_table_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_name"
    t.uuid "admin_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "upload_errors"
    t.json "upload_warnings"
    t.boolean "successful"
    t.index ["admin_user_id"], name: "index_data_table_uploads_on_admin_user_id"
  end

  create_table "inf_arch_tabs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inf_arch_upload_id"
    t.string "tab_name"
    t.json "tree"
    t.json "process_errors"
    t.json "process_warnings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inf_arch_upload_id"], name: "index_inf_arch_tabs_on_inf_arch_upload_id"
  end

  create_table "inf_arch_uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_name"
    t.uuid "admin_user_id"
    t.json "upload_errors", default: []
    t.json "upload_warnings", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_inf_arch_uploads_on_admin_user_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.tsvector "content"
    t.string "searchable_type"
    t.uuid "searchable_id"
    t.text "searchable_name"
    t.datetime "searchable_created_at"
    t.datetime "searchable_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content"], name: "index_pg_search_documents_on_content", using: :gin
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "concept_translations", "concepts", on_delete: :cascade
  add_foreign_key "concepts", "categories", on_delete: :nullify
  add_foreign_key "data_elements", "concepts", on_delete: :nullify
  add_foreign_key "data_table_rows", "concepts"
  add_foreign_key "data_table_rows", "data_table_uploads"
  add_foreign_key "data_table_tabs", "data_table_uploads"
  add_foreign_key "data_table_uploads", "admin_users"
  add_foreign_key "inf_arch_tabs", "inf_arch_uploads"
  add_foreign_key "inf_arch_uploads", "admin_users"
end
