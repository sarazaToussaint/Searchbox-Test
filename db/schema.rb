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

ActiveRecord::Schema[8.0].define(version: 2025_04_18_000004) do
  create_table "article_views", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "search_query_id", null: false
    t.integer "view_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "search_query_id"], name: "index_article_views_on_article_id_and_search_query_id", unique: true
    t.index ["article_id", "view_count"], name: "index_article_views_on_article_and_count"
    t.index ["article_id"], name: "index_article_views_on_article_id"
    t.index ["search_query_id", "article_id", "view_count"], name: "index_article_views_on_search_article_count"
    t.index ["search_query_id"], name: "index_article_views_on_search_query_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.string "author"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_articles_on_category"
    t.index ["title", "content"], name: "index_articles_on_title_and_content"
    t.index ["title"], name: "index_articles_on_title"
  end

  create_table "search_queries", force: :cascade do |t|
    t.string "term", null: false
    t.integer "results_count", default: 0
    t.boolean "is_complete", default: true
    t.datetime "last_searched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_identifier"
    t.string "ip_address"
    t.integer "search_count", default: 0, null: false
    t.index ["ip_address"], name: "index_search_queries_on_ip_address"
    t.index ["last_searched_at"], name: "index_search_queries_on_last_searched_at"
    t.index ["results_count"], name: "index_search_queries_on_results_count"
    t.index ["term", "results_count"], name: "index_search_queries_on_term_and_results_count"
    t.index ["term", "search_count"], name: "index_search_queries_on_term_and_count"
    t.index ["term", "user_identifier", "ip_address"], name: "index_search_queries_on_term_user_ip", unique: true
    t.index ["term"], name: "index_search_queries_on_term"
    t.index ["user_identifier", "created_at"], name: "index_search_queries_on_user_id_created_at"
    t.index ["user_identifier"], name: "index_search_queries_on_user_identifier"
  end

  add_foreign_key "article_views", "articles"
  add_foreign_key "article_views", "search_queries"
end
