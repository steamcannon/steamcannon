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
  module Storage
    class Ec2Storage
      extend ActiveSupport::Memoizable

      def initialize(access_key, secret_access_key, cloud_specific_hacks)
        @access_key = access_key
        @secret_access_key = secret_access_key
        @cloud_specific_hacks = cloud_specific_hacks
      end

      def write(artifact_version)
        content_type = artifact_version.archive_content_type
        file = artifact_version.archive.to_file
        object = s3_object(artifact_version)
        object.put(file, 'private', {'Content-Type' => content_type})
      end

      def delete(artifact_version)
        s3_object(artifact_version).delete
      end

      def public_url(artifact_version)
        expires_at = Time.now + 1.hour

        options = {
          :access_key => @access_key,
          :secret_access_key => @secret_access_key,
          :method => :get,
          :bucket => bucket_name,
          :resource => path(artifact_version),
          :expires_at => expires_at
        }
        S3::Signature.generate_temporary_url(options)
      end

      def bucket_name
        prefix = "SteamCannonArtifacts_"
        @cloud_specific_hacks.unique_bucket_name(prefix)
      end

      def bucket
        # Ensure our bucket exists and has correct permissions
        s3 = Aws::S3.new(@access_key, @secret_access_key)
        bucket = Aws::S3::Bucket.create(s3, bucket_name, true, 'private')
        bucket
      end
      memoize :bucket

      def s3_object(artifact_version)
        bucket.key(path(artifact_version))
      end

      def path(artifact_version)
        "#{artifact_version.id}/#{artifact_version.archive_file_name}"
      end

    end
  end
end
