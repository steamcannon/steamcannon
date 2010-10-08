class AddStorageVolumeCapacityToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :storage_volume_capacity, :string
  end

  def self.down
    remove_column :images, :storage_volume_capacity
  end
end
