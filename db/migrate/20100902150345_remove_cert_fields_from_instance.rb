class RemoveCertFieldsFromInstance < ActiveRecord::Migration

  def self.up
    remove_column :instances, :client_cert
    remove_column :instances, :client_key
    remove_column :instances, :server_cert
    remove_column :instances, :server_key
  end

  def self.down
    add_column :instances, :server_key, :string, :limit => 1024
    add_column :instances, :server_cert, :string, :limit => 1024
    add_column :instances, :client_key, :string, :limit => 1024
    add_column :instances, :client_cert, :string, :limit => 1024
  end
end
