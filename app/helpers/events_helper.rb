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

module EventsHelper
  def formatted_event(event)
    accum = formatted_event_subject(event.event_subject)
    accum << formatted_event_operation(event).html_safe
    accum << formatted_event_status(event).html_safe
    accum << " (#{event.message})" if event.message
    accum
  end

  def formatted_event_timestamp(event)
    time_ago_in_words(event.created_at) + " ago"
  end
  
  def formatted_event_subject(event_subject)
    link_to_unless_current content_tag(:span, event_subject.name, :class => 'event_subject'), events_for_subject_path(event_subject)
  end


  def formatted_event_operation(event)
    prefix = ' '
    case event.operation
    when :state_transition
      operation = 'transitioned'
    else
      prefix << 'attempted to '
      operation = event.operation.to_s.humanize.downcase
    end
    prefix + content_tag(:span, operation, :class => 'operation')
  end

  def formatted_event_status(event)
    case event.operation
    when :state_transition
      prefix = ' to '
    else
      prefix = " with a result of "
    end
    prefix + content_tag(:span, event.status.to_s.humanize.downcase, :class => event_status_dom_class(event))
  end

  def event_status_dom_class(event)
    klass = %w{ status }
    case event.status.to_s
    when /fail/
      klass << 'failure'
    when 'success', 'deployed', 'running', 'stopped'
      klass << 'success'
    end
    klass.join(' ')
  end
end
