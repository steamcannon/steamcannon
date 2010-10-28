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


describe AgentServices::ModCluster do
  before(:each) do
    @service = Factory.build(:service, :name => 'mod_cluster')
    @environment = Factory(:environment)
    @agent_service = AgentServices::ModCluster.new(@service, @environment)
    @instance_service = Factory(:instance_service)
    Service.stub!(:by_name).and_return(Factory(:service))
    @jboss_instance_service = Factory.build(:instance_service)
    @jboss_instance_service.stub!(:configure_service)
    @environment.stub_chain(:instance_services, :running, :for_service).and_return([@jboss_instance_service])
  end

  describe 'configure_instance' do
    it "should return true" do
      @agent_service.configure_instance_service(@instance_service).should == true
    end

    it "should configure the jboss instance_services" do
      @jboss_instance_service.should_receive(:configure_service)
      @agent_service.configure_instance_service(@instance_service)
    end
  end

  describe "open_ports" do
    it "should have port 80" do
      @agent_service.open_ports.should include(80)
    end
  end

  describe "url_for_instance" do
    before(:each) do
      @instance = Factory(:instance)
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
  end

  describe "url_for_instance_service" do
    it "should equal url_for_instance" do
      instance_service = Factory(:instance_service)
      @agent_service.should_receive(:url_for_instance).with(instance_service.instance).and_return('url')
      @agent_service.url_for_instance_service(instance_service).should == 'url'
    end
  end
end
