require 'open-uri'

class App 

  UPLOADS_DIR = Rails.root.join('public', 'uploads')

  attr_reader :id, :archive, :status

  def initialize attrs = {}
    @archive = attrs[:archive]
    @status = attrs[:status] || 'staged'
    @id = File.basename(filename, ".war") unless filename.blank?
  end

  def filename
    @archive.respond_to?(:original_filename) ? @archive.original_filename : @archive
  end

  def url
    "http://#{Instance.frontend.public_dns}/#@id" rescue nil
  end

  def self.all
    u = uploads
    p = pending
    d = deployed
    u - p + p - d + d
  end

  def self.uploads
    Dir.glob(UPLOADS_DIR.join('*.war')).map{|x| App.new(:archive => File.basename(x))}
  end

  def self.pending
    Instance.backend.list.map{|x| App.new(:archive => x, :status => 'pending')} rescue []
  end

  def self.deployed
    if frontend = Instance.frontend
      content = open("http://#{frontend.public_dns}/mod_cluster_manager") {|f| f.read}
      if content =~ /<h3>Contexts:<\/h3><pre>(.*?)<\/pre>/m
        contexts = $1
        return contexts.gsub(/<.*?>/,'').split("/n").
          map{|x| x.scan(/\/(.*?), Status: (\w+)/) }[0].
          map{|n,e| App.new(:archive=>"#{n}.war", :status => e=='ENABLED' ? 'running' : 'disabled')}
      end
    end
    return []
  rescue
    return []
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
    path = UPLOADS_DIR.join(archive.original_filename)
    File.open(path, 'w') do |file| 
      file.write(archive.read)
    end
    Instance.backend.deploy path
    true
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.error e.inspect
    RAILS_DEFAULT_LOGGER.error e.backtrace.join("\n")
    false
  end

  def destroy
    Instance.backend.undeploy archive
  end

  def errors
    []
  end

  def cluster
    @cluster ||= Cluster.new
  end

  def == other
    self.id == other.id
  end

  def eql? other
    self == other
  end

  def hash
    self.id.hash
  end
end
