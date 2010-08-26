class User < ActiveRecord::Base
  has_many :apps
  has_many :environments
  has_many :deployments
  has_many :app_versions, :through => :apps

  acts_as_authentic do |c|
  end

  named_scope :visible_to_user, lambda { |user|
    { :conditions => user.superuser? ? { } : { :id => user.id } }
  }
  
  def cloud
    Cloud::Deltacloud.new(cloud_username, cloud_password)
  end
end
