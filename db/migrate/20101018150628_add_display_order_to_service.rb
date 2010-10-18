class AddDisplayOrderToService < ActiveRecord::Migration
  def self.up
    add_column :services, :display_order, :integer
  end

  def self.down
    remove_column :services, :display_order
  end
end
