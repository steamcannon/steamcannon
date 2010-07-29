# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100729184743) do

  create_table "app_versions", :force => true do |t|
    t.integer  "app_id"
    t.integer  "version_number"
    t.string   "archive_file_name"
    t.string   "archive_content_type"
    t.string   "archive_file_size"
    t.string   "archive_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apps", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "description"
  end

  create_table "deployments", :force => true do |t|
    t.integer  "environment_id"
    t.integer  "user_id"
    t.string   "datasource"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_version_id"
  end

  create_table "environment_images", :force => true do |t|
    t.integer  "environment_id"
    t.integer  "image_id"
    t.string   "hardware_profile"
    t.integer  "num_instances"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.integer  "platform_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "status",              :default => "stopped"
  end

  create_table "image_roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "name"
    t.string   "cloud_id"
    t.integer  "image_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instances", :force => true do |t|
    t.integer  "environment_id"
    t.integer  "image_id"
    t.string   "name"
    t.string   "cloud_id"
    t.string   "hardware_profile"
    t.string   "status"
    t.string   "public_dns"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platform_version_images", :force => true do |t|
    t.integer  "platform_version_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platform_versions", :force => true do |t|
    t.string   "version_number"
    t.integer  "platform_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platforms", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cloud_username"
    t.string   "cloud_password"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
