class AddStateChangeTimestampToInstance < ActiveRecord::Migration
  def self.up
    add_column :instances, :state_change_timestamp, :datetime
  end

  def self.down
    remove_column :instances, :state_change_timestamp
  end
end
