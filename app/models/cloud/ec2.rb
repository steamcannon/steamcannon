#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

module Cloud
  class Ec2
    extend ActiveSupport::Memoizable

    def initialize(instance)
      @instance = instance
    end

    def multicast_config
      {
        :s3_ping => {
          :pre_signed_put_url => pre_signed_put_url,
          :pre_signed_delete_url => pre_signed_delete_url
        }
      }
    end

    def launch_options
      # TODO: Need to optimize this to not check security groups for
      # every instance we launch
      groups = [base_security_group]
      groups += service_security_groups
      groups.each do |group|
        ensure_security_group(group)
      end
      {:security_group => groups.map { |group| group[:name] }}
    end

    protected

    def user
      @instance.environment.user
    end

    def pre_signed_put_url
      pre_signed_url(:method => :put,
                     :headers => {'x-amz-acl' => 'public-read'})
    end

    def pre_signed_delete_url
      pre_signed_url(:method => :delete)
    end

    def pre_signed_url(options)
      access_key = @instance.cloud.cloud_username
      secret_access_key = @instance.cloud.cloud_password
      environment = @instance.environment
      s3_bucket = multicast_bucket(environment.user)
      s3_resource = "Environment#{environment.id}/instance#{@instance.id}"
      expires_at = @instance.created_at + 1.year

      options.merge!(:access_key => access_key,
                     :secret_access_key => secret_access_key,
                     :bucket => s3_bucket,
                     :resource => s3_resource,
                     :expires_at => expires_at)
      S3::Signature.generate_temporary_url(options)
    end

    def multicast_bucket(user)
      bucket_suffix = Digest::SHA1.hexdigest(user.cloud_username)
      bucket_name = "SteamCannonEnvironments_#{bucket_suffix}"

      s3 = Aws::S3.new(user.cloud_username,
                       user.cloud_password,
                       :multi_thread => true)

      # Ensure our bucket exists and has correct permissions
      bucket = Aws::S3::Bucket.create(s3, bucket_name, true, 'public-read')
      bucket_name
    end
    memoize :multicast_bucket

    def base_security_group
      { :user => user,
        :name => 'steamcannon',
        :description => 'SteamCannon',
        :permissions => [
                         # Allow all traffic inside group
                         :self,
                         # SSH
                         { :protocol => 'tcp',
                           :from_port => '22',
                           :to_port => '22',
                           :cidr_ips => '0.0.0.0/0'
                         },
                         # SteamCannon Agent
                         { :protocol => 'tcp',
                           :from_port => '7575',
                           :to_port => '7575',
                           :cidr_ips => '0.0.0.0/0'
                         }]
      }
    end

    def service_security_groups
      # TODO - pull these from service classes
      [
       # mod_cluster
       { :user => user,
         :name => 'steamcannon_mod_cluster',
         :description => 'SteamCannon mod_cluster service',
         :permissions => [{ :protocol => 'tcp',
                            :from_port => 80,
                            :to_port => 80,
                            :cidr_ips => '0.0.0.0/0'
                          }]
       },
       # jboss_as
       { :user => user,
         :name => 'steamcannon_jboss_as',
         :description => 'SteamCannon jboss_as service',
         :permissions => [{ :protocol => 'tcp',
                            :from_port => 8080,
                            :to_port => 8080,
                            :cidr_ips => '0.0.0.0/0'
                          }]
       }
      ]
    end

    def ensure_security_group(options)
      user = options[:user]
      group_name = options[:name]
      group_description = options[:description]

      ec2 = Aws::Ec2.new(user.cloud_username, user.cloud_password)
      begin
        group = ec2.describe_security_groups([group_name])[0]
      rescue Aws::AwsError => e
        # group doesn't exist, create it
        ec2.create_security_group(group_name, group_description)
        group = ec2.describe_security_groups([group_name])[0]
      end

      # Make sure the group has the desired permissions
      options[:permissions].each do |permission|
        if permission == :self
          permission = {:owner => group[:aws_owner], :group => group_name}
        end
        ensure_security_group_permission(ec2, group, permission)
      end
    end

    def ensure_security_group_permission(ec2, group, permission)
      unless group[:aws_perms].include?(permission)
        if permission[:protocol]
          ec2.authorize_security_group_IP_ingress(group[:aws_group_name],
                                                  permission[:from_port],
                                                  permission[:to_port],
                                                  permission[:protocol],
                                                  permission[:cidr_ips])
        else
          ec2.authorize_security_group_named_ingress(group[:aws_group_name],
                                                     permission[:owner],
                                                     permission[:group])
        end
      end
    rescue Aws::AwsError => e
      # Amazon doesn't always report new permissions immediately so sometimes
      # we try to create a group permission after it already exists
      # Ignore AWS errors for now
      log(e)
      log(e.backtrace)
    end

    def log(msg)
      Rails.logger.info("Cloud::Ec2[Instance:#{@instance.id} (#{@instance.name})]: #{msg}")
    end

  end
end
