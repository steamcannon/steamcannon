class AddKeysAndCertsToInstance < ActiveRecord::Migration
  def self.up
    add_column :instances, :server_key, :string, :limit => 1024
    add_column :instances, :server_cert, :string, :limit => 1024
    add_column :instances, :client_key, :string, :limit => 1024
    add_column :instances, :client_cert, :string, :limit => 1024
  end

  def self.down
    remove_column :instances, :client_cert
    remove_column :instances, :client_key
    remove_column :instances, :server_cert
    remove_column :instances, :server_key
  end
end
