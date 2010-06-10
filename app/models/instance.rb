class Instance
  DEPLOY_DIR = "/opt/jboss-as6/server/cluster-ec2/farm/"
  
  def initialize attrs = {}
    @attrs = attrs
    @attrs[:image_id] ||= APP_CONFIG['backend_image_id']
    @attrs[:key_pair_name] ||= APP_CONFIG['key_pair_name'] || "default"
  end

  def method_missing attr
    @attrs[attr]
  end

  def to_json options = {}
    @attrs.to_json options
  end

  def to_xml options = {}
    options[:root] ||= self.class.name.downcase
    @attrs.to_xml options
  end

  def backend?
    image_id == APP_CONFIG['backend_image_id']
  end

  def frontend?
    image_id == APP_CONFIG['frontend_image_id']
  end

  def management?
    image_id == APP_CONFIG['management_image_id']
  end

  def running?
    status == 'running'
  end

  def started?
    %w{pending running}.include? status
  end

  def self.backend
    all.find {|x| x.backend? && x.running? }
  end

  def self.frontend
    all.find {|x| x.frontend? && x.running? }
  end

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

  def self.started 
    all.select {|x| x.started?}
  end

  def deploy_path
    APP_CONFIG['deploy_dir'] || DEPLOY_DIR
  end

  # Required ActiveRecord interface

  def self.all
    Thread.current[:instances] ||= CLOUD.instances 
  end

  def self.find id
    all.find {|x| x.id == id}
  end

  def id
    @attrs[:id]
  end

  # Used by url_for
  def new_record?
    id.nil?
  end

  # Used by url_for
  def to_s
    id
  end

  # This may obviate the to_s def
  def to_param
    to_s
  end

  def save
    CLOUD.launch(image_id, key_pair_name)
  end

  def destroy
    CLOUD.terminate(id)
  end

  def errors
    # TODO
  end

end
