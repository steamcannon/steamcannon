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

    def self.extended base
    end

    def exists?(style_name = default_style)
      if original_filename
        cloud_storage.exists?(path(style_name))
      else
        false
      end
    end

    def to_file(style_name = default_style)
      @queued_for_write[style_name] || cloud_storage.to_file(path(style_name))
    end

    def flush_writes
      @queued_for_write.each do |style_name, file|
        cloud_storage.write(path(style_name), file, self)
      end
      @queued_for_write = {}
    end

    def flush_deletes
      @queued_for_delete.each do |path|
        cloud_storage.delete(path)
      end
      @queued_for_delete = []
    end

    def user
      instance.artifact.user
    end

    def cloud_name
      user.cloud.name
    end

    def cloud_storage
      storage_class = "Cloud::Storage::#{cloud_name.camelize}Storage".constantize
      @cloud_storage ||= storage_class.new(user.cloud_username,
                                           user.cloud_password)
    end

  end
end
