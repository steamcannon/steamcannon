class AddErrorToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :error, :text
  end

  def self.down
    remove_column :events, :error
  end
end
