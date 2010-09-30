class DropInstanceDeployments < ActiveRecord::Migration
  def self.up
    drop_table :instance_deployments
  end

  def self.down
    raise Exception.new('There is no going back!')
  end
end
