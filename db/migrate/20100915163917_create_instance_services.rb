class CreateInstanceServices < ActiveRecord::Migration
  def self.up
    create_table :instance_services do |t|
      t.integer :instance_id
      t.integer :service_id

      t.timestamps
    end
  end

  def self.down
    drop_table :instance_services
  end
end
