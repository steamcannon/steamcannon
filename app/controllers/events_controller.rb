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

class EventsController < ApplicationController
  navigation :environments
  before_filter :require_user
  before_filter :load_event_subject
  before_filter :load_bounds

  def index
    load_entry_points
    load_events
  end

  protected
  def load_event_subject
    @event_subject = current_user.event_subjects.find(params[:subject_id])
  rescue ActiveRecord::RecordNotFound => ex
    flash[:notice] = 'Those requested events do not exist, or are not accessible from your account.'
    redirect_to dashboard_path
  end

  def load_bounds
    @lower_bound, @upper_bound = params[:range].split(':').collect(&:to_i) unless params[:range].blank?
  end

  def load_entry_points
    return unless @event_subject.subject_type == 'Environment'
    @entry_points = @event_subject.event_log_entry_points(:operation => 'start_environment') 
    begin
      @entry_point = Event.find(params[:entry_point]) if params[:entry_point]
    rescue ActiveRecord::RecordNotFound => ex
      #ignore
    end
    
    if @entry_points
      @entry_point ||= @entry_points.last
      @lower_bound = @entry_point.id
      next_entry_point = @entry_points[@entry_points.index(@entry_points.find { |ep| ep.id == @entry_point.id }) + 1]
      @upper_bound = next_entry_point.id if next_entry_point
    end
  end
  
  def load_events
    @events = Event.events_for_subject_and_descendents(@event_subject,
                                                       :lower_bound => @lower_bound,
                                                       :upper_bound => @upper_bound)
  end
  
  
end
