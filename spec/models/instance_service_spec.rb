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

describe InstanceService do
  it { should belong_to :instance }
  it { should belong_to :service }


  before(:each) do
    @instance_service = Factory(:instance_service)
    @mock_agent_service = mock('agent_service')
  end

  it "agent_service should lookup the agent service" do
    AgentServices::Base.should_receive(:instance_for_service).with(@instance_service.service,
                                                                   @instance_service.instance.environment)
    @instance_service.agent_service
  end
  describe 'verify' do
    before(:each) do
      @mock_agent_service.stub!(:configure_instance).and_return(true)
      @instance_service.stub!(:agent_service).and_return(@mock_agent_service)
    end
    
    it 'should delegate configure to the agent service' do
      @mock_agent_service.should_receive(:configure_instance).with(@instance_service.instance).and_return(true)
      @instance_service.should_receive(:agent_service).and_return(@mock_agent_service)
      @instance_service.configure
    end

    it "should set the configured state if configuration occurred" do
      @instance_service.should_receive(:configured!)
      @instance_service.configure
    end

    it "should not change state if the configuration does not occur" do
      @mock_agent_service.should_receive(:configure_instance).with(@instance_service.instance).and_return(false)
      @instance_service.should_not_receive(:configured!)
      @instance_service.configure
    end
  end

  describe 'verify' do
    before(:each) do
      @mock_agent_service.stub!(:verify_instance).and_return(true)
      @instance_service.stub!(:agent_service).and_return(@mock_agent_service)
      @instance_service.current_state = 'configured'
    end
    
    it 'should delegate verify to the agent service' do
      @mock_agent_service.should_receive(:verify_instance).with(@instance_service.instance).and_return(true)
      @instance_service.should_receive(:agent_service).and_return(@mock_agent_service)
      @instance_service.verify
    end

    it "should set the verified state if configuration verified" do
      @instance_service.should_receive(:verified!)
      @instance_service.verify
    end

    it "should not change state if the configuration does not occur" do
      @mock_agent_service.should_receive(:verify_instance).with(@instance_service.instance).and_return(false)
      @instance_service.should_not_receive(:verified!)
      @instance_service.verify
    end
  end
end
