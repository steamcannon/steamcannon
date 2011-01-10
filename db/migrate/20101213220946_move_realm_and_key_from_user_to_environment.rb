
class MoveRealmAndKeyFromUserToEnvironment < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.environments.each do |env|
        env.realm ||= user.default_realm
        env.ssh_key_name = user.ssh_key_name
        env.save(false)
      end
    end
  end

  def self.down
  end
end
