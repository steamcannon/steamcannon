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
    class << self

      def multicast_config(instance)
        access_key = instance.cloud.cloud_username
        secret_access_key = instance.cloud.cloud_password
        environment = instance.environment
        s3_resource = "Environment#{environment.id}/instance#{instance.id}"
        expires_at = instance.created_at + 1.year

        put_url = S3::Signature.
          generate_temporary_url(:access_key => access_key,
                                 :secret_access_key => secret_access_key,
                                 :method => :put,
                                 :bucket => 'ben-test',
                                 :resource => s3_resource,
                                 :expires_at => expires_at,
                                 :headers => {'x-amz-acl' => 'public-read'})
        delete_url = S3::Signature.
          generate_temporary_url(:access_key => access_key,
                                 :secret_access_key => secret_access_key,
                                 :method => :delete,
                                 :bucket => 'ben-test',
                                 :resource => s3_resource,
                                 :expires_at => expires_at)

        {
          :s3_ping => {
            :pre_signed_put_url => put_url,
            :pre_signed_delete_url => delete_url
          }
        }
      end

    end
  end
end
