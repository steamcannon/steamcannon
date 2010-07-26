class Platform < ActiveRecord::Base
  has_many :platform_versions

  def to_s
    name
  end
end
