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

describe InstanceServicesHelper do

  describe "instance_service_link" do
    before(:each) do
      @instance_service = Factory(:instance_service)
    end

    context "service running" do
      before(:each) do
        @instance_service.stub!(:running?).and_return(true)
      end

      it "should link to service url" do
        service_url = 'http://service:8080'
        @instance_service.should_receive(:url).and_return(service_url)
        helper.should_receive(:link_to).with(anything, service_url)
        helper.instance_service_link(@instance_service)
      end

      it "should link with service full name" do
        full_name = 'full_name'
        @instance_service.should_receive(:full_name).and_return(full_name)
        @instance_service.should_receive(:url).and_return('http://service')
        helper.should_receive(:link_to).with(full_name, anything)
        helper.instance_service_link(@instance_service)
      end

      it "shouldn't link if service has no url" do
        service_url = nil
        @instance_service.should_receive(:url).and_return(service_url)
        helper.should_not_receive(:link_to)
        helper.instance_service_link(@instance_service)
      end
    end

    context "service not running" do
      before(:each) do
        @instance_service.stub!(:running?).and_return(false)
      end

      it "shouldn't link to service url" do
        service_url = 'http://service:8080'
        @instance_service.stub!(:url).and_return(service_url)
        helper.should_not_receive(:link_to).with(anything, service_url)
        helper.instance_service_link(@instance_service)
      end
    end
  end

end
