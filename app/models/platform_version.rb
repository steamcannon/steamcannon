class PlatformVersion < ActiveRecord::Base
  belongs_to :platform
  has_many :platform_version_images
  has_many :images, :through => :platform_version_images

  def to_s
    "#{platform} #{version_number}"
  end

  # See Platform.create_from_yaml_file
  def self.new_from_yaml(yaml)
    images = yaml.delete('images') || []
    version = PlatformVersion.new(yaml)
    images.each do |image_yaml|
      version.images << Image.new_from_yaml(image_yaml)
    end
    version
  end
end
