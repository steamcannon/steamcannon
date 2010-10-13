class AddDescriptionToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :description, :string
  end

  def self.down
    remove_column :images, :description
  end
end
