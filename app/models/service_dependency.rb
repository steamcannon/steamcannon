class ServiceDependency < ActiveRecord::Base
  belongs_to :required_service, :class_name => 'Service'
  belongs_to :dependent_service, :class_name => 'Service'
end
