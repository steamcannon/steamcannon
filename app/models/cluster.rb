class Cluster

  def running? nodes = Instance.all
    b = nodes.select {|x| x.backend? && x.running?}
    f = nodes.select {|x| x.frontend? && x.running?}
    m = nodes.select {|x| x.management? && x.running?}
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

end
