class DropImageRole < ActiveRecord::Migration
  def self.up
    drop_table :image_roles
    remove_column :images, :image_role_id
  end

  def self.down
  end
end
