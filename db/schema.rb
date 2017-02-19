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

ActiveRecord::Schema.define(version: 20170219190335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string   "title"
    t.string   "author"
    t.date     "publication_date"
    t.text     "image_path"
    t.string   "cover_type"
    t.decimal  "price"
    t.float    "rating"
    t.integer  "num_reviews"
    t.string   "isbn"
    t.text     "description"
    t.string   "age_range"
    t.string   "grade_level"
    t.float    "weight"
    t.string   "dimensions"
    t.text     "tags"
    t.string   "series"
    t.integer  "num_pages"
    t.string   "publisher"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
