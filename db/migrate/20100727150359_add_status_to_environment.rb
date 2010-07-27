class AddStatusToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :status, :string, :default => 'stopped'
  end

  def self.down
    remove_column :environments, :status
  end
end
