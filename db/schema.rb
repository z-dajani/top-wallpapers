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

ActiveRecord::Schema.define(version: 20160108044926) do

  create_table "image_posts", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.string   "permalink"
    t.string   "thumbnail"
    t.integer  "score"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "subreddit"
    t.string   "thumb_img_file_name"
    t.string   "thumb_img_content_type"
    t.integer  "thumb_img_file_size"
    t.datetime "thumb_img_updated_at"
  end

  add_index "image_posts", ["permalink"], name: "index_image_posts_on_permalink", unique: true
  add_index "image_posts", ["thumbnail"], name: "index_image_posts_on_thumbnail", unique: true
  add_index "image_posts", ["url"], name: "index_image_posts_on_url", unique: true

end
