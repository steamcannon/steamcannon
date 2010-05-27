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

  def upload file
    # TODO: figure out why Net::SSH won't authenticate
    `scp -o StrictHostKeyChecking=no #{file} #{public_dns}:#{::INSTANCE_FACTORY.deploy_path}`
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
