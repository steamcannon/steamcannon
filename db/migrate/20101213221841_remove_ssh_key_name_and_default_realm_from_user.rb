class RemoveSshKeyNameAndDefaultRealmFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :default_realm
    remove_column :users, :ssh_key_name
  end

  def self.down
    add_column :users, :default_realm, :string
    add_column :users, :ssh_key_name, :string
  end
end
