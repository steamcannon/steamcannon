class AddMetadataToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :metadata, :text
  end

  def self.down
    remove_column :environments, :metadata
  end
end
