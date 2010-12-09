class User < ActiveRecord::Base
end

class MakeExistingUsersOrganizationAdmins < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.organization_admin = true
      user.save!
    end
  end

  def self.down
    User.all.each do |user|
      user.organization_admin = false
      user.save!
    end
  end
end
