class User < ActiveRecord::Base
  acts_as_authentic do |c|
  end

  def cloud
    Cloud::DeltaCloud.new(cloud_username, cloud_password)
  end
end
