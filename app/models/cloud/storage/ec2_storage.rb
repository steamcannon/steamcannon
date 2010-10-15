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
      end

      def exists?(path)
        s3_object(path).exists?
      end

      def to_file(path)
        file = Tempfile.new(File.basename(path))
        file.write(s3_object(path).data)
        file.rewind
        file
      end

      def write(path, file, attachment)
        content_type = attachment.instance_read(:content_type)
        object = s3_object(path)
        object.put(file, 'private', {'Content-Type' => content_type})
      end

      def delete(path)
        s3_object(path).delete
      end

      def public_url(path)
        expires_at = Time.now + 1.hour

        options = {
          :access_key => @access_key,
          :secret_access_key => @secret_access_key,
          :method => :get,
          :bucket => bucket_name,
          :resource => path,
          :expires_at => expires_at
        }
        S3::Signature.generate_temporary_url(options)
      end


      def bucket_name
        bucket_suffix = Digest::SHA1.hexdigest(Certificate.ca_certificate.certificate)
        "SteamCannonArtifacts_#{bucket_suffix}"
      end

      def bucket
        # Ensure our bucket exists and has correct permissions
        s3 = Aws::S3.new(@access_key, @secret_access_key)
        bucket = Aws::S3::Bucket.create(s3, bucket_name, true, 'private')
        bucket
      end
      memoize :bucket

      def s3_object(path)
        bucket.key(path)
      end

    end
  end
end
