class Deployment < ActiveRecord::Base
  belongs_to :app_version
  belongs_to :environment
  belongs_to :user
end
