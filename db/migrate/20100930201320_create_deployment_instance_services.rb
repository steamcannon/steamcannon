class CreateDeploymentInstanceServices < ActiveRecord::Migration
  def self.up
    create_table :deployment_instance_services do |t|
      t.integer :deployment_id
      t.integer :instance_service_id

      t.timestamps
    end
  end

  def self.down
    drop_table :deployment_instance_services
  end
end
