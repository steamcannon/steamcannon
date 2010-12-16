class EnvironmentUsage
  
  attr_reader :environment, :cloud_helper, :runs
  
  def initialize(environment, cloud_helper)
    @environment = environment
    @cloud_helper = cloud_helper
    load_data
  end

  def instance_data_for_run(run)
    @instance_data_per_run ||= { }
    if !@instance_data_per_run[run.id]
      instance_data = { }
      bounds = run.entry_point_bounds(runs)
      events = Event.with_status(['running', 'stopped'])
      events = Event.limit_to_range(events, bounds.first, bounds.last)
      events = events.find(:all, :conditions => ["event_subject_id in (?)", @environment.event_subject.descendants.with_subject_type("Instance").collect(&:id)])
      events.each do |event|
        instance_data[event.event_subject_id] ||= { }
        instance_data[event.event_subject_id][:name] ||= event.event_subject.name
        instance_data[event.event_subject_id][:profile] ||= event.event_subject.metadata[:cloud_hardware_profile]
        instance_data[event.event_subject_id][event.status] = event
      end
      @instance_data_per_run[run.id] = instance_data
    end
    @instance_data_per_run[run.id]
  end

  def total_run_time
    @total_run_time ||= runs.inject(0) do |sum, run|
      sum + (total_run_time_for_single_run(run) || 0)
    end
  end

  def total_run_time_for_single_run(run)
    @total_run_time_for_single_run ||= {}
    if !@total_run_time_for_single_run[run.id]
      @total_run_time_for_single_run[run.id] = 0
      instance_data_for_run(run).keys.each do |subject_id|
        @total_run_time_for_single_run[run.id] += instance_run_time(run, subject_id) || 0
      end
    end
    @total_run_time_for_single_run[run.id]
  end

  def instance_run_time(run, subject_id)
    @instance_run_time ||= { }
    if !@instance_run_time[subject_id]
      instance_events = instance_data_for_run(run)[subject_id]
      if instance_events[:running]
        stop_time = (instance_events[:stopped] ? instance_events[:stopped].created_at : Time.now)
        @instance_run_time[subject_id] = stop_time - instance_events[:running].created_at
      end
    end
    @instance_run_time[subject_id]
  end


  def total_run_cost
    @total_run_cost ||= runs.inject(0) do |sum, run|
      sum + (total_run_cost_for_single_run(run) || 0)
    end
  end

  def total_run_cost_for_single_run(run)
    @total_run_cost_for_single_run ||= {}
    if !@total_run_cost_for_single_run[run.id]
      @total_run_cost_for_single_run[run.id] = 0
      instance_data_for_run(run).keys.each do |subject_id|
        @total_run_cost_for_single_run[run.id] += instance_run_cost(run, subject_id) || 0
      end
    end
    @total_run_cost_for_single_run[run.id]
  end

  def instance_run_cost(run, subject_id)
    @instance_run_cost ||= { }
    if !@instance_run_cost[subject_id]
      seconds = instance_run_time(run, subject_id)
      profile = instance_data_for_run(run)[subject_id][:profile]
      @instance_run_cost[subject_id] = cloud_helper.instance_run_cost(seconds/60, profile) if seconds
    end
    @instance_run_cost[subject_id]
  end

  protected
  def load_data
    @runs = @environment.event_subject.event_log_entry_points(:operation => 'start_environment')
  end
end
