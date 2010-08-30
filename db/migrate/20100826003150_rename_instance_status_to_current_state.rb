class RenameInstanceStatusToCurrentState < ActiveRecord::Migration
  def self.up
    rename_column :instances, :status, :current_state
  end

  def self.down
    rename_column :instances, :current_state, :status
  end
end
