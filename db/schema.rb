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

ActiveRecord::Schema[7.2].define(version: 2024_01_01_000008) do
  # These are extensions that must be enabled in order to support this database
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contents", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "genre", null: false
    t.string "content_type", default: "movie", null: false
    t.string "hls_url"
    t.string "trailer_url"
    t.integer "duration"
    t.float "rating", default: 0.0
    t.integer "year"
    t.string "maturity_rating", default: "TV-14"
    t.string "language", default: "English"
    t.string "director"
    t.string "cast", default: [], array: true
    t.string "tags", default: [], array: true
    t.boolean "featured", default: false
    t.boolean "published", default: true
    t.integer "view_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_type"], name: "index_contents_on_content_type"
    t.index ["featured"], name: "index_contents_on_featured"
    t.index ["genre"], name: "index_contents_on_genre"
    t.index ["published"], name: "index_contents_on_published"
    t.index ["tags"], name: "index_contents_on_tags", using: :gin
  end

  create_table "face_embeddings", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.text "external_face_id"
    t.text "face_data"
    t.string "status", default: "pending"
    t.datetime "enrolled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_face_embeddings_on_profile_id"
    t.index ["status"], name: "index_face_embeddings_on_status"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "avatar_color", default: "#6366f1"
    t.boolean "is_kids", default: false, null: false
    t.boolean "is_default", default: false, null: false
    t.text "preferences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_profiles_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "content_id", null: false
    t.float "score", default: 0.0
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_recommendations_on_content_id"
    t.index ["profile_id", "content_id"], name: "index_recommendations_on_profile_id_and_content_id", unique: true
    t.index ["profile_id", "score"], name: "index_recommendations_on_profile_id_and_score"
    t.index ["profile_id"], name: "index_recommendations_on_profile_id"
  end

  create_table "streams", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "hls_url", null: false
    t.string "category", default: "general"
    t.string "channel_number"
    t.boolean "is_live", default: true
    t.boolean "is_active", default: true
    t.string "logo_url"
    t.jsonb "schedule", default: {}
    t.integer "viewer_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_streams_on_category"
    t.index ["is_active"], name: "index_streams_on_is_active"
    t.index ["is_live"], name: "index_streams_on_is_live"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name", null: false
    t.boolean "admin", default: false, null: false
    t.integer "max_streams", default: 5, null: false
    t.string "subscription_tier", default: "free", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "viewing_histories", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "content_id", null: false
    t.datetime "watched_at", null: false
    t.float "progress", default: 0.0
    t.integer "watch_duration_seconds", default: 0
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_viewing_histories_on_content_id"
    t.index ["profile_id", "content_id"], name: "index_viewing_histories_on_profile_id_and_content_id"
    t.index ["profile_id"], name: "index_viewing_histories_on_profile_id"
    t.index ["watched_at"], name: "index_viewing_histories_on_watched_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "face_embeddings", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "recommendations", "contents"
  add_foreign_key "recommendations", "profiles"
  add_foreign_key "viewing_histories", "contents"
  add_foreign_key "viewing_histories", "profiles"
end
