class CreateEnvironmentImages < ActiveRecord::Migration
  def self.up
    create_table :environment_images do |t|
      t.references :environment
      t.references :image
      t.string :hardware_profile
      t.integer :num_instances

      t.timestamps
    end
  end

  def self.down
    drop_table :environment_images
  end
end
