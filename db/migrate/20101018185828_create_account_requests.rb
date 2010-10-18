class CreateAccountRequests < ActiveRecord::Migration
  def self.up
    create_table :account_requests do |t|
      t.string :email
      t.text :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :account_requests
  end
end
