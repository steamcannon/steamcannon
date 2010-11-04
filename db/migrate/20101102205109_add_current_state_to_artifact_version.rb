class AddCurrentStateToArtifactVersion < ActiveRecord::Migration
  def self.up
    add_column :artifact_versions, :current_state, :string
  end

  def self.down
    remove_column :artifact_versions, :current_state
  end
end
