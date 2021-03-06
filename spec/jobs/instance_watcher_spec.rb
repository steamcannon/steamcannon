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

describe InstanceWatcher do
  before(:each) do
    @instance_watcher = InstanceWatcher.new
  end

  it "should update starting, attaching_volume, configuring, verifying, and terminating instances" do
    @instance_watcher.should_receive(:update_starting)
    @instance_watcher.should_receive(:update_attaching_volume)
    @instance_watcher.should_receive(:update_configuring)
    @instance_watcher.should_receive(:update_verifying)
    @instance_watcher.should_receive(:update_terminating)
    @instance_watcher.run
  end

  describe 'update_starting' do
    before(:each) do
      @instance = mock_model(Instance)
      @instance.stub!(:attach_volume!)
      @instance.stub!(:attaching_volume?).and_return(true)
      Instance.stub!(:starting).and_return([@instance])
    end
    
    it "should try to transition to attaching_volume" do
      @instance.should_receive(:attach_volume!)
      @instance_watcher.update_starting
    end
    
    it "should transition each starting instance to configuring if it did not move to attaching_volume" do
      @instance.should_receive(:attaching_volume?).and_return(false)
      @instance.should_receive(:move_to_configure)
      @instance_watcher.update_starting
    end

    it "should not transition each starting instance to configuring if it did move to attaching_volume" do
      @instance.should_receive(:attaching_volume?).and_return(true)
      @instance.should_not_receive(:move_to_configure)
      @instance_watcher.update_starting
    end
  end

  it "should attempt to attach the volume for any attaching_volume instances" do
    instance = mock_model(Instance)
    instance.should_receive(:attach_volume)
    Instance.stub!(:attaching_volume).and_return([instance])
    @instance_watcher.update_attaching_volume
  end
  
  it "should attempt to configure any configuring instances" do
    instance = mock_model(Instance)
    instance.should_receive(:configure_agent)
    Instance.stub!(:configuring).and_return([instance])
    @instance_watcher.update_configuring
  end

  it "should attempt to verify any verifying instances" do
    instance = mock_model(Instance)
    instance.should_receive(:verify_agent)
    Instance.stub!(:verifying).and_return([instance])
    @instance_watcher.update_verifying
  end

  it "should transition each terminating instance to stopped" do
    instance = mock_model(Instance)
    instance.should_receive(:stopped!)
    Instance.stub!(:terminating).and_return([instance])
    @instance_watcher.update_terminating
  end
end
