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

ActiveRecord::Schema[8.1].define(version: 2026_04_27_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "doctors", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "fax_number"
    t.string "name"
    t.bigint "patient_id", null: false
    t.string "phone_number"
    t.string "practice"
    t.string "speciality"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_doctors_on_patient_id"
  end

  create_table "medications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_started"
    t.date "date_stopped"
    t.bigint "doctor_id"
    t.string "dosage"
    t.string "drug_class"
    t.string "name", null: false
    t.text "notes"
    t.bigint "patient_id", null: false
    t.text "side_effects"
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_medications_on_doctor_id"
    t.index ["patient_id"], name: "index_medications_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_patients_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "absolute_expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["absolute_expires_at"], name: "index_sessions_on_absolute_expires_at"
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "doctors", "patients"
  add_foreign_key "medications", "doctors"
  add_foreign_key "medications", "patients"
  add_foreign_key "patients", "users"
  add_foreign_key "sessions", "users"
end
