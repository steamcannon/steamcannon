class App

  # The war file's basename
  attr_accessor :id

  def initialize attrs = {}
    @id = attrs[:id]
  end

  def self.all
    []
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

  def save
    # TODO
  end

  def destroy
    # TODO
  end

  def errors
    []
  end

end
