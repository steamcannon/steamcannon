class StorageVolume < ActiveRecord::Base
end

class DropPendingDestroyFromStorageVolume < ActiveRecord::Migration
  def self.up
    remove_column :storage_volumes, :pending_destroy
    StorageVolume.reset_column_information
  end

  def self.down
    add_column :storage_volumes, :pending_destroy, :boolean
    StorageVolume.reset_column_information
  end
end
