class Environment < ActiveRecord::Base
  has_many :deployments
  has_many :environment_images, :dependent => :destroy
  has_many :images, :through => :environment_images
  belongs_to :platform_version
  belongs_to :user
  attr_protected :user
  accepts_nested_attributes_for :environment_images
  validates_presence_of :name

  named_scope :running, :conditions => { :status => 'running' }

  def platform
    platform_version.platform
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
