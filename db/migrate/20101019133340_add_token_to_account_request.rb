class AddTokenToAccountRequest < ActiveRecord::Migration
  def self.up
    add_column :account_requests, :token, :string
  end

  def self.down
    remove_column :account_requests, :token
  end
end
