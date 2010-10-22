class AddStateChangeTimestampToDeploymentInstanceService < ActiveRecord::Migration
  def self.up
    add_column :deployment_instance_services, :state_change_timestamp, :timestamp
  end

  def self.down
    remove_column :deployment_instance_services, :state_change_timestamp
  end
end
