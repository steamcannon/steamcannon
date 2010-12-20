class User < ActiveRecord::Base
end

class RemoveCloudCredentialsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :cloud_username
    remove_column :users, :crypted_cloud_password
    User.reset_column_information
  end

  def self.down
    add_column :users, :cloud_username, :string
    add_column :users, :crypted_cloud_password, :string
    User.reset_column_information

    User.all.each do |user|
      organization = user.organization
      user.update_attributes(:cloud_username => organization.cloud_username,
                             :crypted_cloud_password => organization.crypted_cloud_password)
    end
  end
end
