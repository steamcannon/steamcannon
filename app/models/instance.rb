class Instance
  
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

  def self.backend
    all.find {|x| x.backend? && x.running? }
  end

  def self.frontend
    all.find {|x| x.frontend? && x.running? }
  end

  def deploy file
    # `scp -o StrictHostKeyChecking=no #{file} #{public_dns}:#{::INSTANCE_FACTORY.deploy_path}`
    remote = File.join(::INSTANCE_FACTORY.deploy_path, File.basename(file))
    Net::SSH.start(public_dns, APP_CONFIG['ssh_username'], :keys => [APP_CONFIG['ssh_private_key_file']]) do |ssh|
      ssh.scp.upload! file.to_s, remote
      # touch the file to mitigate a potential race condition with the deploy scanner
      ssh.exec! "touch #{remote}" 
    end
  end

  def undeploy file
    remote = File.join(::INSTANCE_FACTORY.deploy_path, File.basename(file))
    Net::SSH.start(public_dns, APP_CONFIG['ssh_username'], :keys => [APP_CONFIG['ssh_private_key_file']]) do |ssh|
      ssh.exec! "rm -f #{remote}" 
    end
  end

  def list dir = ::INSTANCE_FACTORY.deploy_path
    result = []
    Net::SSH.start(public_dns, APP_CONFIG['ssh_username'], :keys => [APP_CONFIG['ssh_private_key_file']]) do |ssh|
      ssh.exec!("ls #{dir}") do |ch, stream, data|
        result = data.split("\n") if stream == :stdout
      end
    end
    result
  end

  # Required ActiveRecord interface

  def self.all
    ::INSTANCE_FACTORY.instances
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
    ::INSTANCE_FACTORY.launch(image_id, key_pair_name)
  end

  def destroy
    ::INSTANCE_FACTORY.terminate(id)
  end

  def errors
    # TODO
  end

end
