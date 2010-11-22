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


class InstanceReaper

  def run
    # Check all running instances and ensure that they are still running
    # otherwise make them unavailable
    Instance.running.each { |i| i.unreachable! if (i.cloud.nil? || !i.reachable?) }

    check_unreachable
  end

  def check_unreachable
    Instance.unreachable.each do |instance|
      unless instance.cloud.nil?
        if instance.reachable?
          instance.run!
        elsif instance.terminated?
          instance.stop!
        elsif instance.unreachable_for_too_long?
          instance.stop!
        end
      end
    end
  end

end
