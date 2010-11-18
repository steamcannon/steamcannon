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
  
  def index
    @events = @event_subject.descendants.inject(@event_subject.events) do |events, descendant|
      events + descendant.events
    end.sort_by(&:created_at)
  end

  protected
  def load_event_subject
    @event_subject = current_user.event_subjects.find(params[:subject_id])
  rescue ActiveRecord::RecordNotFound => ex
    flash[:notice] = 'Those requested events do not exist, or are not accessible from your account.'
    redirect_to dashboard_path
  end
end