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

ActiveRecord::Schema[8.1].define(version: 2026_09_24_220000) do
  create_table "alembic_flow_definition_summaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "flow_id", null: false
    t.text "summary"
    t.integer "summary_cursor"
    t.datetime "updated_at", null: false
    t.index ["flow_id"], name: "index_alembic_flow_definition_summaries_on_flow_id", unique: true
  end

  create_table "alembic_flow_run_summaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "run_id", null: false
    t.integer "summary_version_id", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_alembic_flow_run_summaries_on_run_id", unique: true
    t.index ["summary_version_id"], name: "index_alembic_flow_run_summaries_on_summary_version_id"
  end

  create_table "alembic_flow_summaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "flow_id", null: false
    t.integer "number", null: false
    t.json "summary"
    t.index ["flow_id", "number"], name: "index_alembic_summary_versions_on_diagnostic_and_number", unique: true
    t.index ["flow_id"], name: "index_alembic_flow_summaries_on_flow_id"
  end

  create_table "alembic_page_versions", force: :cascade do |t|
    t.json "blocks", default: [], null: false
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.integer "page_id", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "number"], name: "index_alembic_page_versions_on_page_id_and_number", unique: true
    t.index ["page_id"], name: "index_alembic_page_versions_on_one_live_per_page", unique: true, where: "status = 'live'"
    t.index ["page_id"], name: "index_alembic_page_versions_on_page_id"
  end

  create_table "alembic_pages", force: :cascade do |t|
    t.json "blocks", default: [], null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_alembic_pages_on_slug", unique: true
  end

  create_table "easy_flow_definitions", force: :cascade do |t|
    t.json "changes_since_version"
    t.datetime "created_at", null: false
    t.integer "definition_cursor"
    t.json "document"
    t.string "kind"
    t.string "persists", default: "unsaved", null: false
    t.string "slug"
    t.string "start_label"
    t.string "status", default: "active", null: false
    t.string "title"
    t.json "undo_history"
    t.json "undone_changes"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_easy_flow_definitions_on_slug", unique: true
  end

  create_table "easy_flow_runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "definition_version_id", null: false
    t.integer "flow_id", null: false
    t.string "label"
    t.integer "owner_id"
    t.string "owner_type"
    t.json "recorded"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["definition_version_id"], name: "index_easy_flow_runs_on_definition_version_id"
    t.index ["flow_id"], name: "index_easy_flow_runs_on_flow_id"
    t.index ["owner_type", "owner_id"], name: "index_easy_flow_runs_on_owner"
  end

  create_table "easy_flow_versions", force: :cascade do |t|
    t.json "changes_captured"
    t.datetime "created_at", null: false
    t.json "definition"
    t.integer "flow_id", null: false
    t.integer "number", null: false
    t.string "status", default: "draft", null: false
    t.index ["flow_id", "number"], name: "index_easy_flow_versions_on_flow_id_and_number", unique: true
    t.index ["flow_id"], name: "index_easy_flow_versions_on_flow_id"
    t.index ["flow_id"], name: "index_easy_flow_versions_on_one_live_per_flow", unique: true, where: "status = 'live'"
  end

  add_foreign_key "alembic_flow_definition_summaries", "easy_flow_definitions", column: "flow_id", on_delete: :cascade
  add_foreign_key "alembic_flow_run_summaries", "alembic_flow_summaries", column: "summary_version_id", on_delete: :cascade
  add_foreign_key "alembic_flow_run_summaries", "easy_flow_runs", column: "run_id", on_delete: :cascade
  add_foreign_key "alembic_flow_summaries", "easy_flow_definitions", column: "flow_id", on_delete: :cascade
  add_foreign_key "alembic_page_versions", "alembic_pages", column: "page_id"
  add_foreign_key "easy_flow_runs", "easy_flow_definitions", column: "flow_id"
  add_foreign_key "easy_flow_runs", "easy_flow_versions", column: "definition_version_id"
  add_foreign_key "easy_flow_versions", "easy_flow_definitions", column: "flow_id"
end
