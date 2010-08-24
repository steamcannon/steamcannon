class Instance < ActiveRecord::Base
  include AuditColumns

  belongs_to :environment
  belongs_to :image

  named_scope :active, :conditions => "status is null or status <> 'stopped'"
  named_scope :inactive, :conditions => "status == 'stopped'"
  named_scope :pending, :conditions => "status == 'pending'"
  named_scope :stopping, :conditions => "status == 'stopping'"

  before_create :generate_certs

  def self.deploy!(image, environment, name, hardware_profile)
    instance = Instance.new(:image_id => image.id,
                            :environment_id => environment.id,
                            :name => name,
                            :hardware_profile => hardware_profile,
                            :status => 'pending')
    instance.audit_action :started
    instance.save!
    InstanceTask.async(:launch_instance, :instance_id => instance.id)
    instance
  end

  def cloud
    environment.user.cloud
  end

  def running?
    status == 'running'
  end

  def stopping?
    status == 'stopping'
  end

  def stop!
    audit_action :stopped
    self.status = 'stopping'
    save!
    InstanceTask.async(:stop_instance, :instance_id => self.id)
  end

  def generate_certs
    self.server_key, self.server_cert = AgentCert.generate("CT Agent", 'serverAuth')
    self.client_key, self.client_cert = AgentCert.generate("CT", 'clientAuth')
  end

end
