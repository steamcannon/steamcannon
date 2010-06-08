class Cluster

  def running? nodes = Instance.started
    b = backend :nodes => nodes, :running => true
    f = frontend :nodes => nodes, :running => true
    m = management :nodes => nodes, :running => true
    b.any? && f.any? && m.any?
  end

  def shutdown
    Instance.started.each do |x| 
      RAILS_DEFAULT_LOGGER.debug "Shutting down #{x}"
      x.destroy
    end
  end

  def startup
    nodes = Instance.started
    %w{backend frontend management}.each do |type|
      image_id = APP_CONFIG[type+'_image_id']
      unless nodes.any? {|x| x.image_id == image_id}
        RAILS_DEFAULT_LOGGER.debug "Starting up a #{type} instance"
        Instance.new(:image_id => image_id).save
      end
    end
    running? nodes
  end

  def management options = {}
    options.fetch(:nodes, Instance.started).select {|x| x.management? && (!options[:running] || x.running?)}
  end
  def backend options = {}
    options.fetch(:nodes, Instance.started).select {|x| x.backend? && (!options[:running] || x.running?)}
  end
  def frontend options = {}
    options.fetch(:nodes, Instance.started).select {|x| x.frontend? && (!options[:running] || x.running?)}
  end

end
