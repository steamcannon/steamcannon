class Image < ActiveRecord::Base
  belongs_to :image_role
  has_many :platform_versions, :through => :platform_version_images
end
