class AddPreserveStorageVolumesToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :preserve_storage_volumes, :boolean, :default => true
  end

  def self.down
    remove_column :environments, :preserve_storage_volumes
  end
end
