class RenamePublicDnsToPublicAddress < ActiveRecord::Migration
  def self.up
    rename_column :instances, :public_dns, :public_address
  end

  def self.down
    rename_column :instances, :private_dns, :public_dns
  end
end
