class AccountRequest < ActiveRecord::Base
end

class AddOrganizationIdToAccountRequest < ActiveRecord::Migration
  def self.up
    add_column :account_requests, :organization_id, :integer
    AccountRequest.reset_column_information
  end

  def self.down
    remove_column :account_requests, :organization_id
    AccountRequest.reset_column_information
  end
end
