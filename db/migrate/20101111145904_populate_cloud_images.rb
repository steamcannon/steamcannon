class Image < ActiveRecord::Base
  has_many :cloud_images
end

class CloudImage < ActiveRecord::Base
  belongs_to :image
end

class PopulateCloudImages < ActiveRecord::Migration
  def self.up
    Image.all.each do |image|
      image.cloud_images.create(:cloud => 'ec2',
                                :region => 'us-east-1',
                                :architecture => 'i386',
                                :cloud_id => image.cloud_id)
    end
  end

  def self.down
    CloudImage.delete_all
  end
end
