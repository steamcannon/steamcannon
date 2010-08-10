class AddUndeployedAtToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :undeployed_at, :datetime, :default => nil
  end

  def self.down
    remove_column :deployments, :undeployed_at
  end
end
