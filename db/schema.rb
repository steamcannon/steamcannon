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

ActiveRecord::Schema.define(:version => 20101118221732) do

  create_table "account_requests", :force => true do |t|
    t.string   "email"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "current_state"
  end

  create_table "artifact_versions", :force => true do |t|
    t.integer  "artifact_id"
    t.integer  "version_number"
    t.string   "archive_file_name"
    t.string   "archive_content_type"
    t.string   "archive_file_size"
    t.string   "archive_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "current_state"
  end

  create_table "artifacts", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "description"
    t.integer  "service_id"
  end

  create_table "certificates", :force => true do |t|
    t.string   "cert_type"
    t.text     "certificate"
    t.text     "keypair"
    t.integer  "certifiable_id"
    t.string   "certifiable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cloud_images", :force => true do |t|
    t.string   "cloud"
    t.string   "region"
    t.string   "architecture"
    t.string   "cloud_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deployment_instance_services", :force => true do |t|
    t.integer  "deployment_id"
    t.integer  "instance_service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "current_state"
    t.datetime "state_change_timestamp"
  end

  create_table "deployments", :force => true do |t|
    t.integer  "environment_id"
    t.integer  "user_id"
    t.string   "datasource"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "artifact_version_id"
    t.datetime "undeployed_at"
    t.datetime "deployed_at"
    t.integer  "deployed_by"
    t.integer  "undeployed_by"
    t.string   "agent_artifact_identifier"
    t.string   "current_state"
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
    t.string   "current_state",            :default => "stopped"
    t.boolean  "preserve_storage_volumes", :default => true
    t.text     "metadata"
  end

  add_index "environments", ["current_state"], :name => "index_environments_on_current_state"

  create_table "event_subjects", :force => true do |t|
    t.string   "subject_type"
    t.integer  "subject_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "name"
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_subjects", ["ancestry"], :name => "index_event_subjects_on_ancestry"

  create_table "events", :force => true do |t|
    t.integer  "event_subject_id"
    t.string   "operation"
    t.string   "status"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_services", :force => true do |t|
    t.integer  "image_id"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "storage_volume_capacity"
    t.string   "storage_volume_device"
    t.string   "description"
    t.boolean  "can_scale_out",           :default => false
  end

  create_table "instance_services", :force => true do |t|
    t.integer  "instance_id"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "current_state"
    t.datetime "state_change_timestamp"
    t.text     "metadata"
  end

  create_table "instances", :force => true do |t|
    t.integer  "environment_id"
    t.integer  "image_id"
    t.string   "cloud_id"
    t.string   "hardware_profile"
    t.string   "current_state"
    t.string   "public_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.integer  "started_by"
    t.datetime "stopped_at"
    t.integer  "stopped_by"
    t.datetime "state_change_timestamp"
    t.string   "private_address"
    t.integer  "number"
  end

  add_index "instances", ["current_state"], :name => "index_instances_on_current_state"

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

  create_table "service_dependencies", :force => true do |t|
    t.integer  "required_service_id"
    t.integer  "dependent_service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
    t.boolean  "allow_artifacts", :default => false
  end

  create_table "storage_volumes", :force => true do |t|
    t.string   "volume_identifier"
    t.integer  "environment_image_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pending_destroy"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                     :null => false
    t.string   "crypted_password",                          :null => false
    t.string   "password_salt",                             :null => false
    t.string   "persistence_token",                         :null => false
    t.string   "single_access_token",                       :null => false
    t.string   "perishable_token",                          :null => false
    t.integer  "login_count",            :default => 0,     :null => false
    t.integer  "failed_login_count",     :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cloud_username"
    t.boolean  "superuser",              :default => false
    t.string   "crypted_cloud_password"
    t.string   "ssh_key_name",           :default => ""
    t.string   "default_realm"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
