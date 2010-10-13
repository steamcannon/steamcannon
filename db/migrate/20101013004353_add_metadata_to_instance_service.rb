class AddMetadataToInstanceService < ActiveRecord::Migration
  def self.up
    add_column :instance_services, :metadata, :text
  end

  def self.down
    remove_column :instance_services, :metadata
  end
end
