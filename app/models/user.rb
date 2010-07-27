class User < ActiveRecord::Base
  has_many :apps
  has_many :environments
  has_many :deployments

  acts_as_authentic do |c|
  end

  def cloud
    Cloud::Deltacloud.new(cloud_username, cloud_password)
  end
end
