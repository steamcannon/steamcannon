class Environment < ActiveRecord::Base
  has_many :deployments
  has_many :environment_images, :dependent => :destroy
  has_many :images, :through => :environment_images
  has_many :instances
  belongs_to :platform_version
  belongs_to :user
  attr_protected :user_id
  accepts_nested_attributes_for :environment_images
  validates_presence_of :name, :user

  named_scope :running, :conditions => { :status => 'running' }

  def platform
    platform_version.platform
  end

  def running?
    status == 'running'
  end

  def start!
    unless self.running?
      environment_images.each do |env_image|
        env_image.num_instances.times do |i|
          env_image.start!(i+1)
        end
      end
      self.status = 'running'
      save!
    end
  end

  def stop!
    deployments.active.each(&:undeploy!)
    instances.active.each(&:stop!)
    self.status = 'stopped'
    save!
  end
end
