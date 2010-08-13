class Instance < ActiveRecord::Base
  include AuditColumns

  belongs_to :environment
  belongs_to :image

  named_scope :active, :conditions => "status is null or status <> 'stopped'"
  named_scope :inactive, :conditions => "status == 'stopped'"
  named_scope :pending, :conditions => "status == 'pending'"
  named_scope :stopping, :conditions => "status == 'stopping'"

  before_create :generate_certs

  DEPLOY_DIR = "/opt/jboss-as6/server/cluster-ec2/farm/"

  def self.deploy!(image_id, environment_id, name, hardware_profile)
    # cloud id and public_dns are temporary hacks
    random_cloud_id = "i-#{(1000000000 + rand(3000000000)).to_s(16)}"
    instance = Instance.new(:image_id => image_id,
                            :environment_id => environment_id,
                            :name => name,
                            :cloud_id => random_cloud_id,
                            :hardware_profile => hardware_profile,
                            :status => 'pending',
                            :public_dns => 'ec2-72-44-82-93.z-2.1-compute.amazonaws.com')
    instance.audit_action :started
    instance.save!
    instance
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
  end

  def generate_certs
    self.server_key, self.server_cert = AgentCert.generate("CT Agent", 'serverAuth')
    self.client_key, self.client_cert = AgentCert.generate("CT", 'clientAuth')
  end


  # Code below here is deprecated and will be removed as soon as Host Manager
  # is integrated
  #
  def deploy file
    # `scp -o StrictHostKeyChecking=no #{file} #{public_dns}:#{deploy_path}`
    remote = File.join(deploy_path, File.basename(file))
    ssh do |shell|
      shell.exec!("/opt/jboss-as6/bin/twiddle.sh -s $(hostname -i) invoke jboss.deployment:flavor=URL,type=DeploymentScanner stop")
      shell.scp.upload! file.to_s, remote
      shell.exec!("/opt/jboss-as6/bin/twiddle.sh -s $(hostname -i) invoke jboss.deployment:flavor=URL,type=DeploymentScanner start")
    end
    remote
  end

  def undeploy file
    remote = File.join(deploy_path, File.basename(file))
    ssh do |shell|
      shell.exec! "rm -f #{remote}"
    end
  end

  def list dir = deploy_path
    result = []
    ssh do |shell|
      shell.exec!("ls #{dir}") do |ch, stream, data|
        result = data.split("\n") if stream == :stdout
      end
    end
    result
  end

  def ssh
    options = APP_CONFIG['ssh_private_key_file'] ? {:keys => [APP_CONFIG['ssh_private_key_file']]} : {}
    Net::SSH.start(public_dns, APP_CONFIG['ssh_username'], options) do |shell|
      yield shell
    end
  end

  def deploy_path
    APP_CONFIG['deploy_dir'] || DEPLOY_DIR
  end

end
