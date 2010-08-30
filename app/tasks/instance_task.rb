class InstanceTask < TorqueBox::Messaging::Task

  def launch_instance(payload)
    instance = Instance.find(payload[:instance_id])
    instance.start!
  end

  def stop_instance(payload)
    instance = Instance.find(payload[:instance_id])
    instance.terminate!
  end
end
