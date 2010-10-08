class AddStorageVolumeDeviceToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :storage_volume_device, :string
  end

  def self.down
    remove_column :images, :storage_volume_device
  end
end
