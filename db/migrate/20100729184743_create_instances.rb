class CreateInstances < ActiveRecord::Migration
  def self.up
    create_table :instances do |t|
      t.references :environment
      t.references :image
      t.string :name
      t.string :cloud_id
      t.string :hardware_profile
      t.string :status
      t.string :public_dns

      t.timestamps
    end
  end

  def self.down
    drop_table :instances
  end
end
