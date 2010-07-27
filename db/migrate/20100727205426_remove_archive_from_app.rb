class RemoveArchiveFromApp < ActiveRecord::Migration
  def self.up
    remove_column :apps, :archive_file_name
    remove_column :apps, :archive_content_type
    remove_column :apps, :archive_file_size
    remove_column :apps, :archive_updated_at
  end

  def self.down
    add_column :apps, :archive_updated_at, :string
    add_column :apps, :archive_file_size, :string
    add_column :apps, :archive_content_type, :string
    add_column :apps, :archive_file_name, :string
  end
end
