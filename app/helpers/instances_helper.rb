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
end
