class InstanceWatcher

  def run
    update_pending
    update_stopping
  end

  def update_pending
    # TODO: This is a bit inefficient to do one at a time
    Instance.pending.each { |i| update_attributes_from_cloud(i) }
  end

  def update_stopping
    # TODO: This is a bit inefficient to do one at a time
    Instance.stopping.each { |i| update_attributes_from_cloud(i) }
  end

  def update_attributes_from_cloud(instance)
    cloud_instance = instance.cloud.instance(instance.cloud_id)
    cloud_state = cloud_instance.state.downcase
    instance.status = cloud_state == 'terminated' ? 'stopped' : cloud_state
    instance.public_dns = cloud_instance.public_addresses.first
    instance.save!
  end
end
