class AddStateChangeTimestampToInstanceService < ActiveRecord::Migration
  def self.up
    add_column :instance_services, :state_change_timestamp, :datetime
  end

  def self.down
    remove_column :instance_services, :state_change_timestamp
  end
end
