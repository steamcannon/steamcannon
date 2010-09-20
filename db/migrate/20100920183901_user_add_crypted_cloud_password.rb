class UserAddCryptedCloudPassword < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :crypted_cloud_password
    end
    remove_column :users, :cloud_password
  end

  def self.down
    remove_column :users, :crypted_cloud_password
  end
end
