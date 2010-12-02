class ClearExistingInstances < ActiveRecord::Migration
  def self.up
    Instance.all.each do |instance|
      puts "checking instance #{instance.id} (:#{instance.current_state})..."
      if instance.events.empty?
        puts '-> no events'
        if %w{ running stopping terminating stopped unreachable }.include?(instance.current_state)
          puts '--> logging :running'
          instance.log_event(:operation => :state_transition, :status => :running, :created_at => instance.started_at)
        end

        if instance.current_state == 'stopped'
          puts '--> logging :stopped'
          instance.log_event(:operation => :state_transition, :status => :stopped, :created_at => instance.stopped_at)
        end
      end
      
      if %w{ configure_failed start_failed stopped }.include?(instance.current_state)
        puts '-> destroying!'
        instance.destroy
      end
    end

  end

  def self.down
  end
end
