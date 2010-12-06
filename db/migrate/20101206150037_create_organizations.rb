class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string :name
      t.string :cloud_username
      t.string :crypted_cloud_password

      t.timestamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
