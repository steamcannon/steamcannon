class RenameEnvironmentStatusToCurrentState < ActiveRecord::Migration
  def self.up
    rename_column :environments, :status, :current_state
  end

  def self.down
    rename_column :environments, :current_state, :status
  end
end
