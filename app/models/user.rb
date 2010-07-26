class User < ActiveRecord::Base
  has_many :environments

  acts_as_authentic do |c|
  end

  def cloud
    Cloud::Deltacloud.new(cloud_username, cloud_password)
  end
end
