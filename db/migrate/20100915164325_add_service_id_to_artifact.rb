class AddServiceIdToArtifact < ActiveRecord::Migration
  def self.up
    add_column :artifacts, :service_id, :integer
  end

  def self.down
    remove_column :artifacts, :service_id
  end
end
