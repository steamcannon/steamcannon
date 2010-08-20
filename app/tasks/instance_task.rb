require 'torquebox/messaging/task'

class InstanceTask < TorqueBox::Messaging::Task

  def launch_instance(payload)
    instance = Instance.find(payload[:instance_id])
    cloud_instance = instance.cloud.launch(instance.image.cloud_id,
                                           payload[:bucket])
    instance.update_attributes(:cloud_id => cloud_instance.id,
                               :status => cloud_instance.state.downcase,
                               :public_dns => cloud_instance.public_addresses.first)
    instance.save!
  end

  def stop_instance(payload)
    instance = Instance.find(payload[:instance_id])
    instance.cloud.terminate(instance.cloud_id)
    instance.status = 'stopping'
    instance.save!
  end
end
