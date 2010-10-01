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

describe InstanceServiceWatcher do
  before(:each) do
    @instance_watcher = InstanceServiceWatcher.new
  end

  it "should update configuring and verifying instances" do
    @instance_watcher.should_receive(:configure_configuring_instance_services)
    @instance_watcher.should_receive(:verify_verifying_instance_services)
    @instance_watcher.run
  end

  it "should attempt to configure any configuring instance_services" do
    instance_service = mock_model(InstanceService)
    instance_service.should_receive(:configure_service)
    InstanceService.stub!(:configuring).and_return([instance_service])
    @instance_watcher.configure_configuring_instance_services
  end

  it "should attempt to verify any verifying instance_services" do
    instance_service = mock_model(InstanceService)
    instance_service.should_receive(:verify_service)
    InstanceService.stub!(:verifying).and_return([instance_service])
    @instance_watcher.verify_verifying_instance_services
  end

end
