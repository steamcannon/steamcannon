class Image < ActiveRecord::Base
  belongs_to :image_role
  has_many :platform_versions, :through => :platform_version_images
  has_many :instances

  validates_presence_of :image_role

  # See Platform.create_from_yaml_file
  def self.new_from_yaml(yaml)
    image_role = yaml['image_role']
    unless image_role.nil?
      yaml['image_role'] = ImageRole.find_or_create_by_name(image_role)
    end
    Image.find_or_create_by_cloud_id(yaml)
  end
end
