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

class Event < ActiveRecord::Base
  belongs_to :event_subject

  def subject
    event_subject.subject
  end

  def operation
    val = super
    val && val.to_sym
  end

  def operation=(val)
    super(val && val.to_s)
  end

  def status
    val = super
    val && val.to_sym
  end

  def status=(val)
    super(val && val.to_s)
  end

  def error=(error)
    if error
      if error.respond_to?(:message)
        error = {
          :type => error.class.name,
          :message => error.message,
          :backtrace => error.backtrace ? error.backtrace.join("\n") : '' }
      else
        error = { :type => '', :message => error, :backtrace => '' }
      end
      error = error.to_json
    end

    super(error)
  end

  def error
    error = super
    error = JSON.parse(error, :symbolize_names => true) if error
    error
  end
  
end
