class AddPendingDestroyToStorageVolume < ActiveRecord::Migration
  def self.up
    add_column :storage_volumes, :pending_destroy, :boolean
  end

  def self.down
    remove_column :storage_volumes, :pending_destroy
  end
end
