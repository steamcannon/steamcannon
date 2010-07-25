class PlatformVersionImage < ActiveRecord::Base
  belongs_to :platform_version
  belongs_to :image
end
