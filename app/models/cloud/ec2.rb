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
      # TODO: Need to pull service-specific ports from somewhere else
      user = @instance.environment.user
      ensure_security_group(:user => user,
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
                                             },
                                             # HTTP
                                             { :protocol => 'tcp',
                                               :from_port => '80',
                                               :to_port => '80',
                                               :cidr_ips => '0.0.0.0/0'
                                             },
                                             # JBoss AS
                                             { :protocol => 'tcp',
                                               :from_port => '8080',
                                               :to_port => '8080',
                                               :cidr_ips => '0.0.0.0/0'
                                             }
                                            ])
      {:security_group => ['steamcannon']}
    end

    protected

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
      s3_bucket = find_or_create_multicast_bucket(environment.user)
      s3_resource = "Environment#{environment.id}/instance#{@instance.id}"
      expires_at = @instance.created_at + 1.year

      options.merge!(:access_key => access_key,
                     :secret_access_key => secret_access_key,
                     :bucket => s3_bucket,
                     :resource => s3_resource,
                     :expires_at => expires_at)
      S3::Signature.generate_temporary_url(options)
    end

    def find_or_create_multicast_bucket(user)
      unless @bucket_name
        bucket_suffix = Digest::SHA1.hexdigest(user.cloud_username)
        # "_" required in bucket name to workaround a bug in S3 gem
        @bucket_name = "SteamCannonEnvironments_#{bucket_suffix}"

        service = S3::Service.new(:access_key_id => user.cloud_username,
                                  :secret_access_key => user.cloud_password)

        # Ensure our bucket exists and has correct permissions
        bucket = service.buckets.build(@bucket_name)
        # Unfortunately, the S3 gem does some funkiness with headers
        # here and it has to be :x_amz_acl instead of 'x-amz-acl' like above
        bucket.save(:headers => {:x_amz_acl => 'public-read'})
      end
      @bucket_name
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
        ec2.create_security_group(group_name, group_desc)
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
        if permission[:protocl]
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
    end

  end
end
