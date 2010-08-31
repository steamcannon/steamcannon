class EnvironmentWatcher

  def run
    update_starting
    update_stopping
  end

  def update_starting
    Environment.starting.each { |e| e.run! }
  end

  def update_stopping
    Environment.stopping.each { |e| e.stopped! }
  end
end
