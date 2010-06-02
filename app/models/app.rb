require 'open-uri'

class App 

  attr_accessor :id, :archive

  def initialize attrs = {}
    @archive = attrs[:archive]
    @deployed = attrs[:deployed]
    name = @archive.respond_to?(:original_filename) ? @archive.original_filename : @archive
    @id = File.basename(name, ".war") unless name.blank?
  end

  def deployed?
    @deployed
  end

  def url
    "http://#{Instance.frontend.public_dns}/#@id"
  end

  def self.all
    frontend = Instance.frontend
    raise "No frontend host available" unless frontend
    content = open("http://#{frontend.public_dns}/mod_cluster_manager") {|f| f.read}
    if content =~ /<h3>Contexts:<\/h3><pre>(.*?)<\/pre>/m
      contexts = $1
      contexts.gsub(/<.*?>/,'').split("/n").
        map{|x| x.scan(/\/(.*?), Status: (\w+)/) }[0].
        map{|n,e| App.new(:archive=>"#{n}.war", :deployed=>e=='ENABLED')}
    else
      []
    end
  end

  def self.find id
    all.find {|x| x.id == id}
  end

  # Used by url_for
  def new_record?
    id.nil?
  end

  # Used by url_for
  def to_s
    id
  end

  def to_param
    id
  end

  # Only works if archive is a multipart file upload
  def save
    path = Rails.root.join('public', 'uploads', archive.original_filename)
    File.open(path, 'w') do |file| 
      file.write(archive.read)
    end
    Instance.backend.deploy path
    true
  rescue
    RAILS_DEFAULT_LOGGER.error "#{$!} #{$@}"
    false
  end

  def destroy
    Instance.backend.undeploy archive
  end

  def errors
    []
  end

end
