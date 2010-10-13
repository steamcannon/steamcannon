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


describe AgentServices::Postgresql do
  before(:each) do
    @service = Factory.build(:service, :name => 'postgresql')
    @environment = Factory(:environment)
    @agent_service = AgentServices::Postgresql.new(@service, @environment)
  end

  describe "open_ports" do
    it "should have port 5432" do
      @agent_service.open_ports.should include(5432)
    end
  end


  describe "configure_instance_service" do
    before(:each) do
      @agent_client = mock(AgentClient, :configure => nil)
      @instance_service = Factory(:instance_service)
      @instance_service.stub!(:agent_client).and_return(@agent_client)
      @username_password = { :user => 'username', :pasword => 'password' }
      @agent_service.stub!(:generate_username_and_password).and_return(@username_password)
    end
    
    it "should generate a username and password" do
      @agent_service.should_receive(:generate_username_and_password).and_return(@username_password)
      @agent_service.configure_instance_service(@instance_service)
    end

    it "should configure the service" do
      @agent_client.should_receive(:configure).with({ :create_admin => @username_password }.to_json)
      @agent_service.configure_instance_service(@instance_service)
    end

    it "should return true" do
      @agent_service.configure_instance_service(@instance_service).should be_true
    end

    it "should update the metadata for the instance_service" do
      @agent_service.configure_instance_service(@instance_service)
      @instance_service.reload.metadata.should == { :admin_user => @username_password }
    end
  end

  describe 'generate_username_and_password' do
    it "should return a hash with user and password" do
      SecureRandom.should_receive(:hex).with(30).twice.and_return('1234','abcd')
      @agent_service.send(:generate_username_and_password).should == { :user => '_1234', :password => 'abcd' }
    end
  end
  


=begin
  describe "url_for_instance_service" do
    before(:each) do
      @instance_service = Factory(:instance_service)
      @instance_service.metadata = { :admin_user => { }}
      @instance_service.stub_chain(:instance, :public_dns).and_return('public dns')
    end

    it "should build url for jdbc" do
      url = @agent_service.url_for_instance_service(@instance_service)
      url.start_with?('jdbc:postgresql://').should be_true
    end

    it "should build url for instance's public_dns" do
      instance = Factory(:instance)
      @instance_service.should_receive(:instance).and_return(instance)
      instance.should_receive(:public_dns).and_return('public_dns')
      url = @agent_service.url_for_instance_service(@instance_service)
      url.include?('public_dns').should be_true
    end

    it "should build url for port 5432" do
      url = @agent_service.url_for_instance_service(@instance_service)
      url.should match /:5432/
    end

    it "should include the username and password" do
      @instance_service.metadata = { :admin_user => { :user => 'username', :password => 'userpassword' } }
      url = @agent_service.url_for_instance_service(@instance_service)
      url.should match /user=username&password=userpassword/
    end
  end
=end




end
