class Platform < ActiveRecord::Base
  has_many :platform_versions
end

class PlatformVersion < ActiveRecord::Base
  belongs_to :platform
  has_many :platform_version_images
  has_many :images, :through => :platform_version_images
end

class PlatformVersionImage < ActiveRecord::Base
  belongs_to :platform_version
  belongs_to :image
end

class AddPostgresImageToJBossEnterprisePlatform < ActiveRecord::Migration
  def self.up
    platform = Platform.find_by_name("JBoss Enterprise 2-Tier")
    unless platform.nil?
      db_role = ImageRole.find_by_name("database")
      db_image = Image.find_by_image_role_id(db_role.id)
      platform_version = platform.platform_versions.first
      PlatformVersionImage.create(:platform_version => platform_version,
                                  :image => db_image)
    end
  end

  def self.down
    platform = Platform.find_by_name("JBoss Enterprise 2-Tier")
    unless platform.nil?
      db_role = ImageRole.find_by_name("database")
      db_image = Image.find_by_image_role_id(db_role.id)
      platform_version = platform.platform_versions.first
      PlatformVersionImage.first(:platform_version => platform_version,
                                 :image => db_image).destroy
    end
  end
end
