class CreateCloudProfiles < ActiveRecord::Migration
  def self.up
    create_table :cloud_profiles do |t|
      t.string :name
      t.string :cloud_name
      t.string :provider_name
      t.string :username
      t.string :crypted_password
      t.integer :organization_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :cloud_profiles
  end
end
