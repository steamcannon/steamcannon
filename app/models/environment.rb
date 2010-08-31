class Environment < ActiveRecord::Base
  include AASM

  has_many :deployments
  has_many :environment_images, :dependent => :destroy
  has_many :images, :through => :environment_images
  has_many :instances
  belongs_to :platform_version
  belongs_to :user
  attr_protected :user_id
  accepts_nested_attributes_for :environment_images
  validates_presence_of :name, :user

  aasm_column :current_state
  aasm_initial_state :stopped
  aasm_state :starting, :enter => :start_environment
  aasm_state :running
  aasm_state :stopping, :enter => :stop_environment
  aasm_state :stopped

  aasm_event :start do
    transitions :to => :starting, :from => :stopped
  end

  aasm_event :run do
    transitions :to => :running, :from => :starting, :guard => :running_all_instances?
  end

  aasm_event :stop do
    transitions :to => :stopping, :from => :running
  end

  aasm_event :stopped do
    transitions :to => :stopped, :from => :stopping, :guard => :stopped_all_instances?
  end

  def platform
    platform_version.platform
  end

  protected

  def start_environment
    environment_images.each do |env_image|
      env_image.num_instances.times do |i|
        env_image.start!(i+1)
      end
    end
  end

  def stop_environment
    deployments.active.each(&:undeploy!)
    instances.active.each(&:stop!)
  end

  def running_all_instances?
    instances.active.all?(&:running?)
  end

  def stopped_all_instances?
    instances.active.count == 0
  end
end
