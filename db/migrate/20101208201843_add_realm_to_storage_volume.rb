class StorageVolume < ActiveRecord::Base
end

class AddRealmToStorageVolume < ActiveRecord::Migration
  def self.up
    add_column :storage_volumes, :realm, :string
    StorageVolume.reset_column_information
  end

  def self.down
    remove_column :storage_volumes, :realm
    StorageVolume.reset_column_information
  end
end
