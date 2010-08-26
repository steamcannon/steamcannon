class InstanceWatcher

  def run
    update_booting
    update_terminating
  end

  def update_booting
    # TODO: This is a bit inefficient to do one at a time
    Instance.booting.each { |i| i.run! }
  end

  def update_terminating
    # TODO: This is a bit inefficient to do one at a time
    Instance.terminating.each { |i| i.stopped! }
  end
end
