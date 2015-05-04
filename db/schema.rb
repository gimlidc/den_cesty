# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150414090335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checkpoints", force: :cascade do |t|
    t.integer "checkid"
    t.integer "meters"
    t.float   "latitude"
    t.float   "longitude"
    t.integer "race_id",   default: 0
  end

  add_index "checkpoints", ["race_id", "checkid"], name: "index_checkpoints_on_race_id_and_checkid", unique: true, using: :btree

  create_table "dcs", force: :cascade do |t|
    t.string   "name_cs",               limit: 255
    t.string   "name_en",               limit: 255
    t.text     "description"
    t.integer  "rules_id"
    t.datetime "start_time"
    t.integer  "shirt_price"
    t.integer  "own_shirt_price"
    t.integer  "reg_price"
    t.integer  "map_bw_price"
    t.integer  "map_color_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "limit"
    t.integer  "polyester_shirt_price"
    t.integer  "scarf_price"
  end

  create_table "events", force: :cascade do |t|
    t.integer  "walker_id"
    t.integer  "eventId"
    t.string   "eventType",    limit: 255
    t.text     "eventData"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "batteryLevel"
    t.integer  "batteryState"
    t.datetime "timestamp"
    t.integer  "race_id",                  default: 0
  end

  add_index "events", ["race_id", "walker_id", "eventId", "timestamp"], name: "index_events_on_race_id_and_walker_id_and_eventId_and_timestamp", using: :btree

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "races", force: :cascade do |t|
    t.string   "name_cs",     limit: 255,                 null: false
    t.string   "name_en",     limit: 255,                 null: false
    t.datetime "start_time",                              null: false
    t.datetime "finish_time",                             null: false
    t.boolean  "visible",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "walker_id"
    t.integer  "dc_id"
    t.boolean  "colour_map"
    t.boolean  "bw_map"
    t.string   "shirt_size",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "canceled",                    default: false
    t.string   "goal",            limit: 255
    t.string   "phone",           limit: 255
    t.boolean  "confirmed",                   default: false
    t.string   "shirt_polyester", limit: 255, default: "NO"
    t.boolean  "scarf",                       default: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "walker_id"
    t.integer  "dc_id"
    t.text     "report_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "results", force: :cascade do |t|
    t.integer  "walker_id"
    t.integer  "dc_id"
    t.float    "distance"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "official"
  end

  create_table "scoreboard", force: :cascade do |t|
    t.integer  "walker_id"
    t.integer  "lastCheckpoint"
    t.integer  "raceState"
    t.integer  "distance"
    t.float    "avgSpeed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "race_id",        default: 0
    t.float    "latitude",       default: 0.0
    t.float    "longitude",      default: 0.0
  end

  add_index "scoreboard", ["race_id", "walker_id"], name: "index_scoreboard_on_race_id_and_walker_id", unique: true, using: :btree

  create_table "walkers", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "surname",                limit: 255
    t.string   "vokativ",                limit: 255
    t.integer  "year"
    t.binary   "photo"
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 128, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sex",                    limit: 255
    t.boolean  "virtual",                            default: false
    t.string   "phone",                  limit: 255
  end

  add_index "walkers", ["email"], name: "index_walkers_on_email", unique: true, using: :btree
  add_index "walkers", ["reset_password_token"], name: "index_walkers_on_reset_password_token", unique: true, using: :btree
  add_index "walkers", ["vokativ"], name: "index_walkers_on_username", using: :btree

end
