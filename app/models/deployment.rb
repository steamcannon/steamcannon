class Deployment < ActiveRecord::Base
  belongs_to :app
  belongs_to :environment
  belongs_to :user
end
