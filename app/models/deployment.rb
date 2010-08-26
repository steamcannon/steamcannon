class Deployment < ActiveRecord::Base
  include AuditColumns

  belongs_to :app_version
  belongs_to :environment
  belongs_to :user

  named_scope :active, :conditions => 'undeployed_at is null'
  named_scope :inactive, :conditions => 'undeployed_at is not null'

  before_create :record_deploy

  def app
    app_version.app
  end

  def undeploy!
    audit_action :undeployed
    save!
  end

  def undeployed?
    !undeployed_at.nil?
  end

  private
  def record_deploy
    audit_action :deployed
  end
end
