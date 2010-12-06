class Organization < ActiveRecord::Base
  has_many :users
end

class User < ActiveRecord::Base
  belongs_to :organization
end

class CreateOrganizationsForExistingUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      org = Organization.new(:name => user.email,
                             :cloud_username => user.cloud_username,
                             :crypted_cloud_password => user.crypted_cloud_password)
      org.users << user
      org.save!
    end
  end

  def self.down
    Organization.delete_all
  end
end
