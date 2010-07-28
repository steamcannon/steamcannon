class Deployment < ActiveRecord::Base
  belongs_to :app_version
  belongs_to :environment
  belongs_to :user

  def app
    app_version.app
  end
end
