class RemoveCloudCredentialsFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :cloud_username
    remove_column :organizations, :crypted_cloud_password
  end

  def self.down
    add_column :organizations, :cloud_username, :string
    add_column :organizations, :crypted_cloud_password, :string
  end
end
