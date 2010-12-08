class AddOrganizationIdToAccountRequest < ActiveRecord::Migration
  def self.up
    add_column :account_requests, :organization_id, :integer
  end

  def self.down
    remove_column :account_requests, :organization_id
  end
end
