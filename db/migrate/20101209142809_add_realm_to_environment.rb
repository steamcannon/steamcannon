class AddRealmToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :realm, :string
  end

  def self.down
    remove_column :environments, :realm
  end
end
