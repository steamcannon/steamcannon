class Cluster

  def running? nodes = Instance.all
    b = backend :nodes => nodes, :running => true
    f = frontend :nodes => nodes, :running => true
    m = management :nodes => nodes, :running => true
    b.any? && f.any? && m.any?
  end

  def shutdown
    Instance.all.each do |x| 
      RAILS_DEFAULT_LOGGER.debug "Shutting down #{x}"
      x.destroy
    end
  end

  def startup
    nodes = Instance.all
    %w{backend frontend management}.each do |type|
      image_id = APP_CONFIG[type+'_image_id']
      unless nodes.any? {|x| x.image_id == image_id && %w{pending running}.include?(x.status)}
        RAILS_DEFAULT_LOGGER.debug "Starting up a #{type} instance"
        Instance.new(:image_id => image_id).save
      end
    end
    running? nodes
  end

  def management options = {}
    options.fetch(:nodes, Instance.all).select {|x| x.management? && (!options[:running] || x.running?)}
  end
  def backend options = {}
    options.fetch(:nodes, Instance.all).select {|x| x.backend? && (!options[:running] || x.running?)}
  end
  def frontend options = {}
    options.fetch(:nodes, Instance.all).select {|x| x.frontend? && (!options[:running] || x.running?)}
  end

end
