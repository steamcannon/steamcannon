class User < ActiveRecord::Base
  acts_as_authentic do |c|
  end

  def cloud
    Cloud::Ec2.new(cloud_username, cloud_password)
  end
end
