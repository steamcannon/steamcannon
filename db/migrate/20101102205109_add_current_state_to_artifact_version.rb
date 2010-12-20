class ArtifactVersion < ActiveRecord::Base
end

class AddCurrentStateToArtifactVersion < ActiveRecord::Migration
  def self.up
    add_column :artifact_versions, :current_state, :string
    ArtifactVersion.reset_column_information
  end

  def self.down
    remove_column :artifact_versions, :current_state
    ArtifactVersion.reset_column_information
  end
end
