class EnvironmentImage < ActiveRecord::Base
  belongs_to :environment
  belongs_to :image

  def start!(instance_number)
    instance = Instance.new(:image_id => image.id,
                            :environment_id => self.environment_id,
                            :name => "#{image.name} ##{instance_number}",
                            :cloud_id => random_cloud_id,
                            :hardware_profile => hardware_profile,
                            :status => 'running',
                            :public_dns => 'ec2-72-44-82-93.z-2.1-compute.amazonaws.com')
    instance.save!
  end

  def random_cloud_id
    "i-#{(1000000000 + rand(3000000000)).to_s(16)}"
  end
end
