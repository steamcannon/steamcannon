class CreateAppVersions < ActiveRecord::Migration
  def self.up
    create_table :app_versions do |t|
      t.references :app
      t.integer :version_number
      t.string :archive_file_name
      t.string :archive_content_type
      t.string :archive_file_size
      t.string :archive_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :app_versions
  end
end
