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
  class Ec2 < Cloud::Base

    def multicast_config(instance)
      {
        :s3_ping => {
          :pre_signed_put_url => pre_signed_put_url(instance),
          :pre_signed_delete_url => pre_signed_delete_url(instance)
        }
      }
    end

    def launch_options(instance)
      # TODO: Need to optimize this to not check security groups for
      # every instance we launch
      groups = [base_security_group]
      groups += service_security_groups(instance)
      groups.each do |group|
        ensure_security_group(group)
      end
      {
        :security_group => groups.map { |group| group[:name] }
      }
    end

    def running_instances
      return [] if access_key.blank? or secret_access_key.blank?
      ec2 = Aws::Ec2.new(access_key, secret_access_key)
      all = ec2.describe_instances.map do |instance|
        instance.merge(:id => instance[:aws_instance_id],
                       :image => instance[:aws_image_id],
                       :address => instance[:dns_name])
      end
      all.select { |i| i[:aws_state] == 'running' }
    rescue Aws::AwsError => e
      # If we encounter any Amazon errors, log them and pretend we have no
      # running instances for now
      log(e)
      log(e.backtrace)
      []
    end
    memoize :running_instances

    def runaway_instances
      candidates = running_instances.select { |i| i[:aws_groups].include?('steamcannon') }
      managed_ids = managed_instances.map { |i| i[:id] }
      candidates.reject { |i| managed_ids.include?(i[:id]) }
    end

    def unique_bucket_name(prefix)
      sc_salt = Digest::SHA1.hexdigest(Certificate.ca_certificate.certificate)
      creds_salt = Digest::SHA1.hexdigest(access_key)
      suffix = Digest::SHA1.hexdigest("#{sc_salt} #{creds_salt}")
      "#{prefix}#{suffix}"
    end

    INSTANCE_COSTS = {
      'us-east-1' => {
        'm1.small' => 0.085,
        'm1.large' => 0.34,
        'm1.xlarge' => 0.68,
        't1.micro' => 0.02,
        'm2.xlarge' => 0.5,
        'm2.2xlarge' => 1.0,
        'm2.4xlarge' => 2.0,
        'c1.medium' => 0.17,
        'c1.xlarge' => 0.68
      }
    }
    
    def instance_run_cost(minutes, hardware_profile)
      #TODO: this will need to be passed a region when we have support
      #for that
      hours = minutes ? (minutes.to_i/60 + (minutes%60 > 0 ? 1 : 0)) : 0.0
      cost_per_hour = INSTANCE_COSTS['us-east-1'][hardware_profile] || 0.0
      hours * cost_per_hour
    end

    protected

    def access_key
      @cloud_profile.username
    end

    def secret_access_key
      @cloud_profile.password
    end

    def pre_signed_put_url(instance)
      pre_signed_url(instance, :method => :put,
                     :headers => {'x-amz-acl' => 'public-read'})
    end

    def pre_signed_delete_url(instance)
      pre_signed_url(instance, :method => :delete)
    end

    def pre_signed_url(instance, options)
      environment = instance.environment
      s3_bucket = multicast_bucket
      s3_resource = "Environment#{environment.id}/instance#{instance.id}"
      expires_at = instance.created_at + 1.year

      options.merge!(:access_key => access_key,
                     :secret_access_key => secret_access_key,
                     :bucket => s3_bucket,
                     :resource => s3_resource,
                     :expires_at => expires_at)
      S3::Signature.generate_temporary_url(options)
    end

    def multicast_bucket
      bucket_name = unique_bucket_name("SteamCannonEnvironments_")

      s3 = Aws::S3.new(access_key, secret_access_key)

      # Ensure our bucket exists and has correct permissions
      bucket = Aws::S3::Bucket.create(s3, bucket_name, true, 'public-read')
      bucket_name
    end
    memoize :multicast_bucket

    def base_security_group
      { :cloud_profile => @cloud_profile,
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

    def service_security_groups(instance)
      agent_services(instance).map do |agent_service|
        security_group_from_service(agent_service)
      end
    end

    def security_group_from_service(agent_service)
      name = "steamcannon_#{agent_service.service.name}"
      description = "SteamCannon #{agent_service.service.full_name} Service"
      permissions = agent_service.open_ports.map do |port|
        { :protocol => 'tcp',
          :from_port => port,
          :to_port => port,
          :cidr_ips => '0.0.0.0/0'
        }

      end
      { :cloud_profile => @cloud_profile,
        :name => name,
        :description => description,
        :permissions => permissions
      }
    end

    def agent_services(instance)
      environment = instance.environment
      instance.image.services.map do |service|
        AgentServices::Base.instance_for_service(service, environment)
      end
    end

    def ensure_security_group(options)
      group_name = options[:name]
      group_description = options[:description]

      ec2 = Aws::Ec2.new(access_key, secret_access_key)
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

  end
end
