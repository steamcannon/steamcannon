class InstanceWatcher

  def run
    # TODO: This is a bit inefficient
    Instance.pending.each do |instance|
      cloud_instance = instance.cloud.instance(instance.cloud_id)
      instance.update_attributes(:status => cloud_instance.state.downcase,
                                 :public_dns => cloud_instance.public_addresses.first)
    end

    Instance.stopping.each do |instance|
      cloud_instance = instance.cloud.instance(instance.cloud_id)
      if cloud_instance.state.downcase == 'terminated'
        instance.update_attributes(:status => 'stopped')
      end
    end
  end
end
