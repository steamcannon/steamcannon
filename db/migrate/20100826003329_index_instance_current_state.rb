class IndexInstanceCurrentState < ActiveRecord::Migration
  def self.up
    add_index :instances, :current_state
  end

  def self.down
    remove_index :instances, :current_state
  end
end
