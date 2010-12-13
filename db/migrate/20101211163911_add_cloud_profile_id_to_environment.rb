class AddCloudProfileIdToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :cloud_profile_id, :integer
  end

  def self.down
    remove_column :environments, :cloud_profile_id
  end
end
