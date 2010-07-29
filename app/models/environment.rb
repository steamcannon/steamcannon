class Environment < ActiveRecord::Base
  has_many :deployments
  has_many :environment_images, :dependent => :destroy
  has_many :images, :through => :environment_images
  has_many :instances
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
    unless self.running?
      environment_images.each do |env_image|
        env_image.num_instances.times do |i|
          instance = Instance.new(:image_id => env_image.image.id,
                                  :environment_id => self.id,
                                  :name => "#{env_image.image.name} ##{i+1}",
                                  :cloud_id => "I-80297",
                                  :hardware_profile => env_image.hardware_profile,
                                  :status => 'running',
                                  :public_dns => 'ec2-72-44-82-93.z-2.1-compute.amazonaws.com')
          instance.save!
        end
      end
      self.status = 'running'
      save!
    end
  end

  def stop!
    deployments.destroy_all
    instances.destroy_all
    self.status = 'stopped'
    save!
  end
end
