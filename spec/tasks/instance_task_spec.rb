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

describe InstanceTask do
  before(:each) do
    @instance_task = InstanceTask.new
    @payload = { :instance_id => 123 }
    @instance = mock_model(Instance)
    Instance.stub!(:find).and_return(@instance)
  end

  describe "launch" do
    before(:each) do
      @instance.stub!(:start!)
    end

    it "should find instance by instance_id payload" do
      Instance.should_receive(:find).with(123).and_return(@instance)
      @instance_task.launch_instance(@payload)
    end

    it "should start instance" do
      @instance.should_receive(:start!)
      @instance_task.launch_instance(@payload)
    end
  end

  describe "stop" do
    before(:each) do
      @instance.stub!(:terminate!)
    end

    it "should find instance by instance_id payload" do
      Instance.should_receive(:find).with(123).and_return(@instance)
      @instance_task.stop_instance(@payload)
    end

    it "should terminate instance" do
      @instance.should_receive(:terminate!)
      @instance_task.stop_instance(@payload)
    end
  end
end
