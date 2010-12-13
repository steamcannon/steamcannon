class MoveCredentialsFromOrganizationToCloudProfile < ActiveRecord::Migration
  require 'cloud_profile'
  class ::CloudProfile
    def validate_cloud_credentials
      #noop to skip this validation
    end
  end
  
  def self.up
    Organization.all.each do |org|
      
      profile = org.cloud_profiles.create!(:name => 'Default EC2',
                                           :cloud_name => 'ec2',
                                           :provider_name => 'us-east-1',
                                           :username => org.cloud_username,
                                           :crypted_password => org.crypted_cloud_password)

      (org.environments + org.artifacts).each do |child|
        child.update_attribute(:cloud_profile_id, profile.id)
      end

    end
  end

  def self.down
  end
end
