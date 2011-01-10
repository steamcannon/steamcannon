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

require 'spec_helper'

describe EnvironmentUsage do
  before(:each) do
    @event_subject = mock(EventSubject, :event_log_entry_points => [])
    @environment = mock_model(Environment, :event_subject => @event_subject)
    @cloud_helper = mock('cloud_helper')
    @usage = EnvironmentUsage.new(@environment, @cloud_helper)
    @run = mock('run')
  end
  
  describe "instance_hours_for_single_run" do
    it "should return one i.h. for one instance ran less than an hour" do
      @usage.should_receive(:instance_data_for_run).with(@run).and_return({ :an_event_subject_id => { }})
      @usage.should_receive(:instance_run_time).with(@run, :an_event_subject_id).and_return(5.seconds)
      @usage.instance_hours_for_single_run(@run).should == 1
    end

    it "should return one i.h. for one instance ran less than an hour" do
      @usage.should_receive(:instance_data_for_run).with(@run).and_return({ :an_event_subject_id => { }, :anoter_event_subject_id => { }})
      @usage.should_receive(:instance_run_time).twice().and_return(5.seconds)
      @usage.instance_hours_for_single_run(@run).should == 2
    end

    it "should return two i.h. for one instance ran more than an hour" do
      @usage.should_receive(:instance_data_for_run).with(@run).and_return({ :an_event_subject_id => { }})
      @usage.should_receive(:instance_run_time).with(@run, :an_event_subject_id).and_return(3601.seconds)
      @usage.instance_hours_for_single_run(@run).should == 2
    end

    it "should return zero i.h. for one instance ran 0 seconds" do
      @usage.should_receive(:instance_data_for_run).with(@run).and_return({ :an_event_subject_id => { }})
      @usage.should_receive(:instance_run_time).with(@run, :an_event_subject_id).and_return(0.seconds)
      @usage.instance_hours_for_single_run(@run).should == 0
    end
  end
end
