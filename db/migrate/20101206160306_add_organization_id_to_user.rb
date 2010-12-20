class User < ActiveRecord::Base
end

class AddOrganizationIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :organization_id, :integer
    User.reset_column_information
  end

  def self.down
    remove_column :users, :organization_id
    User.reset_column_information
  end
end
