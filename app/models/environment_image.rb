class EnvironmentImage < ActiveRecord::Base
  belongs_to :environment
  belongs_to :image

  def start!(instance_number)
    instance = Instance.new(:image_id => image.id,
                            :environment_id => self.environment_id,
                            :name => "#{image.name} ##{instance_number}",
                            :cloud_id => "I-80297",
                            :hardware_profile => hardware_profile,
                            :status => 'running',
                            :public_dns => 'ec2-72-44-82-93.z-2.1-compute.amazonaws.com')
    instance.save!
  end
end
