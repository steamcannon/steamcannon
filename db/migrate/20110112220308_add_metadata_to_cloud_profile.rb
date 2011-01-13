class AddMetadataToCloudProfile < ActiveRecord::Migration
  def self.up
    add_column :cloud_profiles, :metadata, :text
  end

  def self.down
    remove_column :cloud_profiles, :metadata
  end
end
