class StorageVolume < ActiveRecord::Base
end

class AddCurrentStateToStorageVolume < ActiveRecord::Migration
  def self.up
    add_column :storage_volumes, :current_state, :string
    add_column :storage_volumes, :state_change_timestamp, :datetime
    StorageVolume.reset_column_information
  end

  def self.down
    remove_column :storage_volumes, :state_change_timestamp
    remove_column :storage_volumes, :current_state
    StorageVolume.reset_column_information
  end
end
