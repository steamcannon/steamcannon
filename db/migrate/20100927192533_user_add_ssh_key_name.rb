class UserAddSshKeyName < ActiveRecord::Migration
  def self.up
    add_column :users, :ssh_key_name, :string, :default => 'default'
    User.reset_column_information
    User.find(:all).each do |u|
      u.ssh_key_name = 'default'
      u.save
    end
  end

  def self.down
    remove_column :users, :ssh_key_name
  end
end
