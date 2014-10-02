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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141002163009) do

  create_table "dcs", :force => true do |t|
    t.string   "name_cs"
    t.string   "name_en"
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

  create_table "events", :force => true do |t|
    t.integer  "walker"
    t.integer  "eventId"
    t.string   "eventType"
    t.text     "eventData"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["walker", "eventId"], :name => "index_events_on_walker_and_eventId", :unique => true

  create_table "posts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer  "walker_id"
    t.integer  "dc_id"
    t.boolean  "colour_map"
    t.boolean  "bw_map"
    t.string   "shirt_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "canceled",        :default => false
    t.string   "goal"
    t.string   "phone"
    t.boolean  "confirmed",       :default => false
    t.string   "shirt_polyester", :default => "NO"
    t.boolean  "scarf",           :default => false
  end

  create_table "reports", :force => true do |t|
    t.integer  "walker_id"
    t.integer  "dc_id"
    t.text     "report_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "results", :force => true do |t|
    t.integer  "walker_id"
    t.integer  "dc_id"
    t.float    "distance"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "official"
  end

  create_table "walkers", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "username"
    t.integer  "year"
    t.binary   "photo"
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sex"
    t.boolean  "virtual",                               :default => false
    t.string   "phone"
  end

  add_index "walkers", ["email"], :name => "index_walkers_on_email", :unique => true
  add_index "walkers", ["reset_password_token"], :name => "index_walkers_on_reset_password_token", :unique => true
  add_index "walkers", ["username"], :name => "index_walkers_on_username", :unique => true

end
