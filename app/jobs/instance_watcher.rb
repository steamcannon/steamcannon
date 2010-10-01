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


class InstanceWatcher

  # TODO: This code is starting to seem a bit repetitive
  def run
    update_starting

    # Purposely put the later states before the earlier ones
    # so an instance can't flow from configuring -> verifying ->
    # configuring_service within a single job execution
    update_verifying
    update_configuring

    update_terminating
  end

  def update_starting
    # TODO: This is a bit inefficient to do one at a time
    Instance.starting.each { |i| i.configure! }
  end

  def update_configuring
    # TODO: This is a bit inefficient to do one at a time
    Instance.configuring.each { |i| i.configure_agent }
  end

  def update_verifying
    # TODO: This is a bit inefficient to do one at a time
    Instance.verifying.each { |i| i.verify_agent }
  end

  def update_terminating
    # TODO: This is a bit inefficient to do one at a time
    Instance.terminating.each { |i| i.stopped! }
  end
end
