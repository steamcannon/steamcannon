class Environment < ActiveRecord::Base
  has_many :deployments
  belongs_to :platform_version
  belongs_to :user
  attr_protected :user

  named_scope :running, :conditions => { :status => 'running' }

  def platform
    platform_version.platform
  end

  def images
    platform_version.images
  end

  def running?
    status == 'running'
  end

  def start!
    self.status = 'running'
    save!
  end

  def stop!
    deployments.destroy_all
    self.status = 'stopped'
    save!
  end
end
