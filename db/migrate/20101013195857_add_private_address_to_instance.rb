class AddPrivateAddressToInstance < ActiveRecord::Migration
  def self.up
    add_column :instances, :private_address, :string
  end

  def self.down
    remove_column :instances, :private_address
  end
end
