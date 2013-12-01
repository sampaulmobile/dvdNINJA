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

ActiveRecord::Schema.define(version: 20131130003420) do

  create_table "actors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "rt_url"
    t.string   "pic_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "castings", force: true do |t|
    t.integer  "movie_id"
    t.integer  "actor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "movies", force: true do |t|
    t.string   "title"
    t.string   "studio"
    t.string   "rating"
    t.integer  "year"
    t.string   "genre"
    t.datetime "release_date"
    t.string   "cover_pic_url"
    t.string   "rt_summary"
    t.integer  "critics_score", default: -1
    t.integer  "users_score",   default: -1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rt_id",         default: "-1"
  end

  add_index "movies", ["title"], name: "index_movies_on_title", unique: true

  create_table "torrents", force: true do |t|
    t.integer  "movie_id"
    t.string   "title"
    t.string   "magnet_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
