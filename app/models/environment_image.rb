class EnvironmentImage < ActiveRecord::Base
  belongs_to :environment
  belongs_to :image
end
