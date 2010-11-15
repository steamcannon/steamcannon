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

  describe "configure_instance_service" do
    before(:each) do
      @agent_client = mock(AgentClient, :configure => nil)
      @instance_service = Factory(:instance_service)
      @instance_service.stub!(:agent_client).and_return(@agent_client)
      @instance_service.stub!(:environment).and_return(@environment)
      @username_password = { :user => 'username', :pasword => 'password' }
      @agent_service.stub!(:multicast_config).and_return({})
      @agent_service.stub!(:proxy_list).and_return(nil)
      @agent_service.stub!(:generate_username_and_password).and_return(@username_password)
    end

    it "should generate a username and password" do
      @agent_service.should_receive(:generate_username_and_password).and_return(@username_password)
      @agent_service.configure_instance_service(@instance_service)
    end

    it "should not generate the username and password if we have one stored on the environment" do
      @environment.metadata = { :jboss_as_admin_user => @username_password }
      @agent_service.should_not_receive(:generate_username_and_password)
      @agent_service.configure_instance_service(@instance_service)
    end

    it "should configure the service" do
      @agent_client.should_receive(:configure)
      @agent_service.configure_instance_service(@instance_service)
    end

    it "should return true" do
      @agent_service.configure_instance_service(@instance_service).should be_true
    end

    it "should update the metadata for the environment" do
      @agent_service.configure_instance_service(@instance_service)
      @instance_service.environment.reload.metadata.should == { :jboss_as_admin_user => @username_password }
    end
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

  describe 'generate_username_and_password' do
    it "should return a hash with user and password" do
      SecureRandom.should_receive(:hex).with(15).and_return('abcd')
      @agent_service.send(:generate_username_and_password).should == { :user => 'admin', :password => 'abcd' }
    end
  end

end
