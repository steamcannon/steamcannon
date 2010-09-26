class InstanceDeployment < ActiveRecord::Base
  belongs_to :instance
  belongs_to :deployment
end
