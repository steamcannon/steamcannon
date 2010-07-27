class AddDescriptionToApp < ActiveRecord::Migration
  def self.up
    add_column :apps, :description, :text
  end

  def self.down
    remove_column :apps, :description
  end
end
