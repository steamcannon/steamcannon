class AddAgentArtifactIdentifierToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :agent_artifact_identifier, :integer
  end

  def self.down
    remove_column :deployments, :agent_artifact_identifier
  end
end
