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

      def initialize(access_key, secret_access_key)
        @access_key = access_key
        @secret_access_key = secret_access_key
        @service = S3::Service.new(:access_key_id => @access_key,
                                   :secret_access_key => @secret_access_key)
      end

      def exists?(path)
        s3_object(path).exists?
      end

      def to_file(path)
        file = Tempfile.new(File.basename(path))
        file.write(s3_object(path).content)
        file.rewind
        file
      end

      def write(path, file, attachment)
        object = s3_object(path)
        object.content = file
        object.content_type = attachment.instance_read(:content_type)
        object.acl = :private
        object.save
      end

      def delete(path)
        s3_object(path).destroy
      end

      protected

      def bucket
        bucket_suffix = Digest::SHA1.hexdigest(@access_key)
        # "_" required in bucket name to workaround a bug in S3 gem
        bucket_name = "SteamCannonArtifacts_#{bucket_suffix}"

        # Ensure our bucket exists and has correct permissions
        bucket = @service.buckets.build(bucket_name)
        bucket.save(:headers => {:x_amz_acl => 'private'})
        bucket
      end
      memoize :bucket

      def s3_object(path)
        bucket.objects.build(path)
      end
    end
  end
end
