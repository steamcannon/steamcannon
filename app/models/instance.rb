class Instance
  
  def initialize attrs = {}
    @attrs = attrs
    @attrs[:image_id] ||= APP_CONFIG['backend_image_id']
    @attrs[:key_pair_name] ||= APP_CONFIG['key_pair_name'] || "default"
  end

  def method_missing attr
    @attrs[attr]
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
