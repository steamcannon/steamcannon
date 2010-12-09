class AddRealmToStorageVolume < ActiveRecord::Migration
  def self.up
    add_column :storage_volumes, :realm, :string
  end

  def self.down
    remove_column :storage_volumes, :realm
  end
end
