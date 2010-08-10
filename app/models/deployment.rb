class Deployment < ActiveRecord::Base
  belongs_to :app_version
  belongs_to :environment
  belongs_to :user

  named_scope :active, :conditions => 'undeployed_at is null'
  named_scope :inactive, :conditions => 'undeployed_at is not null'

  def app
    app_version.app
  end

  def undeploy!
    self.undeployed_at = Time.now
    save!
  end
end
