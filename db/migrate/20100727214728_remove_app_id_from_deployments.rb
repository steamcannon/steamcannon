class RemoveAppIdFromDeployments < ActiveRecord::Migration
  def self.up
    remove_column :deployments, :app_id
  end

  def self.down
    add_column :deployments, :app_id, :integer
  end
end
