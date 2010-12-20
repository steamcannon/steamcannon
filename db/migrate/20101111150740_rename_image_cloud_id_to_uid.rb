class Image < ActiveRecord::Base
end

class RenameImageCloudIdToUid < ActiveRecord::Migration
  def self.up
    rename_column :images, :cloud_id, :uid
    Image.reset_column_information
  end

  def self.down
    rename_column :images, :uid, :cloud_id
    Image.reset_column_information
  end
end
