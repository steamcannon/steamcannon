class MakeDeploymentAgentArtifactIdentifierAString < ActiveRecord::Migration
  def self.up
    change_column :deployments, :agent_artifact_identifier, :string
  end

  def self.down
    change_column :deployments, :agent_artifact_identifier, :integer
  end
end
