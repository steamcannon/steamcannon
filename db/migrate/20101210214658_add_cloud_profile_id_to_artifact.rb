class AddCloudProfileIdToArtifact < ActiveRecord::Migration
  def self.up
    add_column :artifacts, :cloud_profile_id, :integer
  end

  def self.down
    remove_column :artifacts, :cloud_profile_id
  end
end
