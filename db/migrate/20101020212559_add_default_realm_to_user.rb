class AddDefaultRealmToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :default_realm, :string
    puts '*' * 80
    puts "HEY YOU! Edit the account data for a user to set the realm before starting an\nevironment for that user, or scratch your head while looking at a stack trace.\nThe choice is yours."
    puts '*' * 80
  end

  def self.down
    remove_column :users, :default_realm
  end
end
