class InstanceWatcher

  def run
    Instance.pending.each do |instance|
      instance.update_attribute(:status, 'running')
    end

    Instance.stopping.each do |instance|
      instance.update_attribute(:status, 'stopped')
    end
  end
end
