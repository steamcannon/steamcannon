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
    # pending are the wars on the backends
    p = pending
    # wars are only running if they exist on the backends
    result = running & p
    # now we add the pending wars that aren't running
    result += (p - result)
    # and finally the staged wars that aren't pending
    result + (staged - result)
  end

  # the apps in our uploads directory
  def self.staged
    Dir.glob(UPLOADS_DIR.join('*.war')).map{|x| App.new(:archive => File.basename(x))}
  end

  # the apps in the deploy directory on the backends
  def self.pending
    Instance.backend.list.select{|x| x.ends_with?('.war')}.
      map{|x| App.new(:archive => x, :status => 'pending')} rescue []
  end

  # the apps reported as enabled by the mod_cluster_manager
  def self.running
    if frontend = Instance.frontend
      content = open("http://#{frontend.public_dns}/mod_cluster_manager") {|f| f.read}
      contexts = content.scan /<h3>Contexts:<\/h3><pre>(.*?)<\/pre>/m
      return contexts.map {|arr| arr.first.gsub(/<.*?>/,'').split("\n")}.flatten.uniq.
        select{|x| x =~ /ENABLED/}.
        map{|x| App.new(:archive => x.match(/\/(.*?),/)[1]+'.war', :status => 'running')}
    else
      []
    end
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
    if backend = Instance.backend
      backend.deploy path
    end
  end

  def redeploy
    path = UPLOADS_DIR.join(archive)
    Instance.backend.deploy path rescue nil
  end

  def destroy
    Instance.backend.undeploy archive rescue nil
    File.delete(UPLOADS_DIR.join(archive))
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
