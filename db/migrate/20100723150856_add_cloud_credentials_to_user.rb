class AddCloudCredentialsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :cloud_username, :string
    add_column :users, :cloud_password, :string
  end

  def self.down
    remove_column :users, :cloud_password
    remove_column :users, :cloud_username
  end
end
