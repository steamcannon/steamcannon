class AddAllowArtifactsToService < ActiveRecord::Migration
  def self.up
    add_column :services, :allow_artifacts, :boolean, :default => false
  end

  def self.down
    remove_column :services, :allow_artifacts
  end
end
