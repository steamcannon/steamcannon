class EnvironmentImage < ActiveRecord::Base
  belongs_to :environment
  belongs_to :image

  def start!(instance_number)
    name = "#{image.name} ##{instance_number}"
    Instance.deploy!(image, environment, name, hardware_profile)
  end
end
