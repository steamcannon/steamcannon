class RenameImageCloudIdToUid < ActiveRecord::Migration
  def self.up
    rename_column :images, :cloud_id, :uid
  end

  def self.down
    rename_column :images, :uid, :cloud_id
  end
end
