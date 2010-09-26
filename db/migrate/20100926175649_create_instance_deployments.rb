class CreateInstanceDeployments < ActiveRecord::Migration
  def self.up
    create_table :instance_deployments do |t|
      t.integer :instance_id
      t.integer :deployment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :instance_deployments
  end
end
