class RenameAppVersionToArtifactVersion < ActiveRecord::Migration
  def self.up
    rename_table :app_versions, :artifact_versions
    rename_column :deployments, :app_version_id, :artifact_version_id
  end

  def self.down
    rename_table :artifact_version, :app_versions
    rename_column :deployments, :artifact_version_id, :app_version_id
  end
end
