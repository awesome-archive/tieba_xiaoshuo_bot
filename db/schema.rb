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

ActiveRecord::Schema.define(:version => 20121021110658) do

  create_table "chapters", :force => true do |t|
    t.integer  "thread_id"
    t.integer  "fiction_id"
    t.string   "title"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true
  end

  add_index "chapters", ["fiction_id"], :name => "index_chapters_on_fiction_id"

  create_table "errors", :force => true do |t|
    t.string   "exception"
    t.string   "message"
    t.text     "backtrace"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.text     "msg"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fictions", :force => true do |t|
    t.string   "name"
    t.string   "encoded_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "fiction_id"
    t.integer  "user_id"
    t.integer  "chapter_id"
    t.boolean  "active",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "subscriptions", ["chapter_id"], :name => "index_subscriptions_on_chapter_id"
  add_index "subscriptions", ["fiction_id"], :name => "index_subscriptions_on_fiction_id"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "account"
    t.integer  "send_count", :default => 0
    t.boolean  "active",     :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

end
