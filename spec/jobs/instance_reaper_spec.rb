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

describe InstanceReaper do
  before(:each) do
    @instance_reaper = InstanceReaper.new
  end

  it "should check_unreachable" do
    @instance_reaper.should_receive(:check_unreachable)
    @instance_reaper.run
  end

  context "check_unreachable" do
    before(:each) do
      @instance = Factory(:instance, :current_state => 'unreachable')
      @instance.stub!(:cloud).and_return(mock('cloud'))
      Instance.stub!(:unreachable).and_return([@instance])
    end

    it "should find unreachable instances" do
      Instance.should_receive(:unreachable).and_return([])
      @instance_reaper.check_unreachable
    end

    it "should do nothing if can't connect to cloud" do
      @instance.should_receive(:cloud).and_return(nil)
      @instance_reaper.check_unreachable
    end

    it "should run reachable instances" do
      @instance.should_receive(:reachable?).and_return(true)
      @instance.should_receive(:run!)
      @instance_reaper.check_unreachable
    end

    it "should stop terminated instances" do
      @instance.stub!(:reachable?).and_return(false)
      @instance.should_receive(:terminated?).and_return(true)
      @instance.should_receive(:stop!)
      @instance_reaper.check_unreachable
    end

    it "should stop instances that have been unreachable for too long" do
      @instance.stub!(:reachable?).and_return(false)
      @instance.stub!(:terminated?).and_return(false)
      @instance.should_receive(:unreachable_for_too_long?).and_return(true)
      @instance.should_receive(:stop!)
      @instance_reaper.check_unreachable
    end
  end
end
