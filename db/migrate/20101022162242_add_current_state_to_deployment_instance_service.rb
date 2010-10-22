class AddCurrentStateToDeploymentInstanceService < ActiveRecord::Migration
  def self.up
    add_column :deployment_instance_services, :current_state, :string
  end

  def self.down
    remove_column :deployment_instance_services, :current_state
  end
end
