class RenameAppToArtifact < ActiveRecord::Migration
  def self.up
    rename_table :apps, :artifacts
    rename_column :app_versions, :app_id, :artifact_id
  end

  def self.down
    rename_table :artifacts, :apps
    rename_column :app_versions, :artifact_id, :app_id
  end
end
