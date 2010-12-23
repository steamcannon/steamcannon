class Instance < ActiveRecord::Base
  has_events(:subject_name => :name,
             :subject_owner => lambda { |i| i.environment.user },
             :subject_parent => :environment,
             :subject_metadata => :event_subject_metadata)

  belongs_to :environment
  belongs_to :image

  def name
    return "##{number}" if image.blank?
    "#{image.name} ##{number}"
  end

  def event_subject_metadata
    {
      :cloud_instance_id => cloud_id,
      :cloud_image_id => image.cloud_id(hardware_profile, environment.user),
      :cloud_hardware_profile => hardware_profile,
      :started_by => started_by,
      :stopped_by => stopped_by
    }
  end
end

class Image < ActiveRecord::Base
  has_many :cloud_images

  def cloud_id(hardware_profile, user)
    cloud_image = cloud_images.find(:first,
                                    :conditions => {
                                      :cloud => 'ec2',
                                      :region => 'us-east-1',
                                      :architecture => 'i386'})
    cloud_image.nil? ? nil : cloud_image.cloud_id
  end
end

class ClearExistingInstances < ActiveRecord::Migration
  def self.up
    Instance.all.each do |instance|
      puts "checking instance #{instance.id} (:#{instance.current_state})..."
      if !instance.environment
        puts '--> environment has been deleted'
      elsif instance.events.empty?
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
