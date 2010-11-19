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

module StateHelpers
  def self.included(base)
    base.send(:before_save, :set_state_change_timestamp) if base.column_names.include?('state_change_timestamp')
  end

  attr_accessor :last_error
  
  protected
  def stuck_in_state_for_too_long?(too_long = 2.minutes)
    state_change_timestamp <= Time.now - too_long
  end

  def set_state_change_timestamp
    self.state_change_timestamp = Time.now if current_state_changed?
  end
end
