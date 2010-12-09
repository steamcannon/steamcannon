class AddOrganizationAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :organization_admin, :boolean, :default => false
  end

  def self.down
    remove_column :users, :organization_admin
  end
end
