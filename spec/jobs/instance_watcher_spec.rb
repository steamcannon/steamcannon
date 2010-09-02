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

  it "should update starting and terminating instances" do
    @instance_watcher.should_receive(:update_starting)
    @instance_watcher.should_receive(:update_terminating)
    @instance_watcher.run
  end

  it "should transition each starting instance to running" do
    instance = mock_model(Instance)
    instance.should_receive(:run!)
    Instance.stub!(:starting).and_return([instance])
    @instance_watcher.update_starting
  end

  it "should transition each terminating instance to stopped" do
    instance = mock_model(Instance)
    instance.should_receive(:stopped!)
    Instance.stub!(:terminating).and_return([instance])
    @instance_watcher.update_terminating
  end
end
