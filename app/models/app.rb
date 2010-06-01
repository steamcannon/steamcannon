
class App 

  attr_accessor :id, :archive

  def initialize attrs = {}
    @archive = attrs[:archive]
    @id = File.basename(@archive, ".war") unless @archive.blank?
  end

  def deployed?
    true
  end

  def url
    "http://wherever.com"
  end

  def self.all
    []
  end

  def self.find id
    all.find {|x| x.id == id} || App.new
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

  def save
    true
  end

  def destroy
    # TODO
  end

  def errors
    []
  end

end
