class Environment < ActiveRecord::Base
  belongs_to :user
end

class UpdateRealmOnRunningEnvironments < ActiveRecord::Migration
  def self.up
    Environment.all.each do |env|
      env.update_attribute(:realm, env.user.default_realm) unless env.realm
    end
  end

  def self.down
  end
end
