class CreatePlatformVersionImages < ActiveRecord::Migration
  def self.up
    create_table :platform_version_images do |t|
      t.references :platform_version
      t.references :image

      t.timestamps
    end
  end

  def self.down
    drop_table :platform_version_images
  end
end
