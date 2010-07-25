class CreatePlatformVersions < ActiveRecord::Migration
  def self.up
    create_table :platform_versions do |t|
      t.string :version_number
      t.references :platform

      t.timestamps
    end
  end

  def self.down
    drop_table :platform_versions
  end
end
