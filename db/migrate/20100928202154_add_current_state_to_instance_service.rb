class AddCurrentStateToInstanceService < ActiveRecord::Migration
  def self.up
    add_column :instance_services, :current_state, :string
  end

  def self.down
    remove_column :instance_services, :current_state
  end
end
