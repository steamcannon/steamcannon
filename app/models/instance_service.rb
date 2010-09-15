class InstanceService < ActiveRecord::Base
  belongs_to :instance
  belongs_to :service
end
