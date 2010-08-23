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
    # TODO: This needs to be done via async messaging and not hang
    # the web request
    cloud_instance = environment.user.cloud.launch(image.cloud_id, 'asdf')
    # cloud id and public_dns are temporary hacks
    random_cloud_id = "i-#{(1000000000 + rand(3000000000)).to_s(16)}"
    instance = Instance.new(:image_id => image.id,
                            :environment_id => environment.id,
                            :name => name,
                            :cloud_id => cloud_instance.id,
                            :hardware_profile => hardware_profile,
                            :status => cloud_instance.state.downcase,
                            :public_dns => cloud_instance.public_addresses.first)
    instance.audit_action :started
    instance.save!
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
    cloud.terminate(cloud_id)
    audit_action :stopped
    self.status = 'stopping'
    save!
  end

  def generate_certs
    self.server_key, self.server_cert = AgentCert.generate("CT Agent", 'serverAuth')
    self.client_key, self.client_cert = AgentCert.generate("CT", 'clientAuth')
  end

end
