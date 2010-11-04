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


module DeploymentsHelper

  def deployment_state(deployment)
    if deployment.is_deployed?
      "Deployed"
    elsif deployment.current_state == 'undeployed'
      "Undeployed"
    else
      "Pending Deployment"
    end
  end

  def deployment_artifact_versions_for_select
    latest = []
    rest = []
    current_user.artifacts.sort_by(&:name).each do |artifact|
      versions = artifact.artifact_versions.all.collect { |av| [av.to_s, av.id ] }
      latest += [versions.shift]
      rest += versions
    end
    grouped_options_for_select([['Latest Versions:', latest], ['Prior Versions:', rest]])
  end
end
