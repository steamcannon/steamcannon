class AddAuditColumnsToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :deployed_at, :datetime
    add_column :deployments, :deployed_by, :integer
    add_column :deployments, :undeployed_by, :integer
  end

  def self.down
    remove_column :deployments, :undeployed_by
    remove_column :deployments, :deployed_by
    remove_column :deployments, :deployed_at
  end
end
