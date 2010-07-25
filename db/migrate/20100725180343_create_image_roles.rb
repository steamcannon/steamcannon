class CreateImageRoles < ActiveRecord::Migration
  def self.up
    create_table :image_roles do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :image_roles
  end
end
