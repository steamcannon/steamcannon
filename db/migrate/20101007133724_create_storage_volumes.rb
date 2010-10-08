class CreateStorageVolumes < ActiveRecord::Migration
  def self.up
    create_table :storage_volumes do |t|
      t.string :volume_identifier
      t.integer :environment_image_id
      t.integer :instance_id

      t.timestamps
    end
  end

  def self.down
    drop_table :storage_volumes
  end
end
