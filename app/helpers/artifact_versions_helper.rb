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


module ArtifactVersionsHelper

  def artifact_version_download_link(artifact_version)
    file_name = h(artifact_version.archive_file_name)
    if artifact_version.uploading?
      "Uploading to Cloud"
    elsif artifact_version.upload_failed?
      "Upload Failed"
    elsif artifact_version.public_url
      link_to(file_name, artifact_version.public_url)
    else
      file_name
    end
  end
end
