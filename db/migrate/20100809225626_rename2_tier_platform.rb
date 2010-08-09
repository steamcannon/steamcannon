class Platform < ActiveRecord::Base
  has_many :platform_versions
end

class PlatformVersion < ActiveRecord::Base
  belongs_to :platform
  has_many :platform_version_images
  has_many :images, :through => :platform_version_images
end

class Rename2TierPlatform < ActiveRecord::Migration
  def self.up
    platform = Platform.find_by_name("JBoss Community 2-tier")
    unless platform.nil?
      platform.name = "JBoss Enterprise 2-Tier"
      platform.save!

      platform_version = platform.platform_versions.first
      platform_version.version_number = ""
      platform_version.save!
    end
  end

  def self.down
    platform = Platform.find_by_name("JBoss Enterprise 2-Tier")
    unless platform.nil?
      platform.name = "JBoss Community 2-tier"
      platform.save!

      platform_version = platform.platform_versions.first
      platform_version.version_number = "1.0.0.Beta2"
      platform_version.save!
    end
  end
end
