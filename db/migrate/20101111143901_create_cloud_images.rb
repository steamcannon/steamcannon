class CreateCloudImages < ActiveRecord::Migration
  def self.up
    create_table :cloud_images do |t|
      t.string :cloud
      t.string :region
      t.string :architecture
      t.string :cloud_id
      t.references :image

      t.timestamps
    end
  end

  def self.down
    drop_table :cloud_images
  end
end
