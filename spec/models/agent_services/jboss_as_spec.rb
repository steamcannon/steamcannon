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


describe AgentServices::JbossAs do
  before(:each) do
    @service = Factory.build(:service, :name => 'jboss_as')
    @environment = Factory(:environment)
    @agent_service = AgentServices::JbossAs.new(@service, @environment)
  end

  describe "open_ports" do
    it "should have port 8080" do
      @agent_service.open_ports.should include(8080)
    end
  end

  describe "url_for_instance" do
    before(:each) do
      @instance = Factory.build(:instance)
    end

    it "should build url for http" do
      url = @agent_service.url_for_instance(@instance)
      url.start_with?('http://').should be(true)
    end

    it "should build url for instance's public_address" do
      @instance.should_receive(:public_address).and_return('public_address')
      url = @agent_service.url_for_instance(@instance)
      url.include?('public_address').should be(true)
    end

    it "should build url for port 8080" do
      url = @agent_service.url_for_instance(@instance)
      url.end_with?(':8080').should be(true)
    end
  end

  describe "url_for_instance_service" do
    it "should return url_for_instance" do
      instance_service = Factory(:instance_service)
      instance = Factory(:instance)
      instance_service.should_receive(:instance).and_return(instance)
      @agent_service.should_receive(:url_for_instance).with(instance).and_return('url')
      @agent_service.url_for_instance_service(instance_service).should == 'url'
    end
  end

end
