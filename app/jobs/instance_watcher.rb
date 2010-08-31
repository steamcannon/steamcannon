class InstanceWatcher

  def run
    update_starting
    update_terminating
  end

  def update_starting
    # TODO: This is a bit inefficient to do one at a time
    Instance.starting.each { |i| i.run! }
  end

  def update_terminating
    # TODO: This is a bit inefficient to do one at a time
    Instance.terminating.each { |i| i.stopped! }
  end
end
