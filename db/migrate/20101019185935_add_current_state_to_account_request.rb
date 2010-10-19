class AddCurrentStateToAccountRequest < ActiveRecord::Migration
  def self.up
    add_column :account_requests, :current_state, :string
  end

  def self.down
    remove_column :account_requests, :current_state
  end
end
