class IndexEnvironmentCurrentState < ActiveRecord::Migration
  def self.up
    add_index :environments, :current_state
  end

  def self.down
    remove_index :environments, :current_state
  end
end
