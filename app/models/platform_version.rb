class PlatformVersion < ActiveRecord::Base
  belongs_to :platform
  has_many :platform_version_images
  has_many :images, :through => :platform_version_images

  def to_s
    "#{platform} #{version_number}"
  end
end
