class Environment < ActiveRecord::Base
  belongs_to :platform_version

  def platform
    platform_version.platform
  end

  def images
    platform_version.images
  end
end
