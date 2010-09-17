class AddCurrentStateToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :current_state, :string
  end

  def self.down
    remove_column :deployments, :current_state
  end
end
