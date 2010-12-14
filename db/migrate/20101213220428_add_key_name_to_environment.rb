class AddKeyNameToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :ssh_key_name, :string
  end

  def self.down
    remove_column :environments, :ssh_key_name
  end
end
