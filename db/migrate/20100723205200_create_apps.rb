class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.string :name, :null => false
      t.string :archive_file_name
      t.string :archive_content_type
      t.string :archive_file_size
      t.string :archive_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :apps
  end
end
