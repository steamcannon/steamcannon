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

  default_scope :order => 'created_at ASC'
  
  named_scope :with_id_gt_or_eq, lambda { |id|
    { :conditions => ['id >= ?', id] }
  }
  
  named_scope :with_id_lt, lambda { |id|
    { :conditions => ['id < ?', id] }
  }

  named_scope :with_status, lambda { |status|
    { :conditions => ['status in (?)', status] }
  }
  
  class << self
    def events_for_subject_and_descendents(event_subject, opts = {})
      lower_bound = opts[:lower_bound]
      upper_bound = opts[:upper_bound]
      events = limit_to_range(event_subject.events, lower_bound, upper_bound)
      event_subject.descendants.inject(events) do |events, descendant|
        events + limit_to_range(descendant.events, lower_bound, upper_bound)
      end.sort_by(&:created_at)
    end

    def limit_to_range(events, lower_bound, upper_bound = nil)
      chain = events
      chain = chain.with_id_gt_or_eq(lower_bound) if lower_bound
      chain = chain.with_id_lt(upper_bound) if upper_bound
      chain
    end

  end

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
          :backtrace => error.backtrace ? error.backtrace.join("\n") : ''
        }
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

  def entry_point_bounds(all_entry_points)
    lower_bound = id
    entry_point_idx = all_entry_points.index(all_entry_points.find { |ep| ep.id == id })
    next_entry_point = all_entry_points[entry_point_idx - 1] if entry_point_idx > 0
    upper_bound = next_entry_point.try(:id)
    [lower_bound, upper_bound]
  end
  
end
