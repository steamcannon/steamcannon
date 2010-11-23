class DropPendingDestroyFromStorageVolume < ActiveRecord::Migration
  def self.up
    remove_column :storage_volumes, :pending_destroy
  end

  def self.down
    add_column :storage_volumes, :pending_destroy, :boolean
  end
end
