class User < ActiveRecord::Base
  has_many :apps
  has_many :environments
  has_many :deployments
  has_many :app_versions, :through => :apps

  acts_as_authentic do |c|
  end

  def cloud
    Cloud::Deltacloud.new(cloud_username, cloud_password)
  end
end
