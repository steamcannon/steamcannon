module InstancesHelper
  def filter(instances, type)
    image_id = case type
               when :management
                 APP_CONFIG['management_image_id']
               when :backend
                 APP_CONFIG['backend_image_id']
               when :frontend
                 APP_CONFIG['frontend_image_id']
               end
    instances.select { |x| x.image_id == image_id && x.status != 'terminated' }
  end

  def render_dns_name instance
    if !instance.public_dns.blank?
      case
      when instance.frontend?
        link_to instance.public_dns, "http://#{instance.public_dns}/mod_cluster_manager"
      when instance.management?
        link_to instance.public_dns, "http://#{instance.public_dns}:7080"
      when instance.backend?
        link_to instance.public_dns, "http://#{instance.public_dns}:8080/admin-console"
      else
        instance.public_dns
      end
    end
  end

  def cluster_status instances = Instance.started
    cluster_incomplete?(instances) ? 'pending' : cluster.running?(instances) ? 'up' : 'down'
  end

  def cluster_incomplete? instances = Instance.started
    [:management, :backend, :frontend].any? {|type| (type_ratio(type, instances) =~ /(\d+)\/\1/).nil?}
  end

  def type_ratio type, instances
    "#{running(type, instances).size}/#{started(type, instances).size}"
  end

  def ajax_loader type, instances
    image_tag('ajax-loader.gif') if running(type, instances).size != started(type, instances).size
  end

  def running type, instances
    cluster.send(type, :nodes => instances, :running => true)
  end

  def started type, instances
    cluster.send(type, :nodes => instances.select {|x| x.started?})
  end
end
