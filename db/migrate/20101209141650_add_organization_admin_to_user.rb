class User < ActiveRecord::Base
end

class AddOrganizationAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :organization_admin, :boolean, :default => false
    User.reset_column_information
  end

  def self.down
    remove_column :users, :organization_admin
    User.reset_column_information
  end
end
