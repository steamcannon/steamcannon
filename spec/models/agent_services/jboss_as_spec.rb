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
    @service = Factory(:service)
    @environment = Factory(:environment)
    @agent_service = AgentServices::JbossAs.new(@service, @environment)
    @instance = Factory(:instance)
    @instance.stub_chain(:cloud_specific_hacks, :multicast_config).and_return({ })
    @instance.services << @service
    @agent_client = mock(:agent_client)
    @agent_client.stub!(:configure)
    @instance.stub!(:agent_client).and_return(@agent_client)
  end

  describe 'configure_instance' do
    context "if there are no mod_cluster instances running" do
      before(:each) do
        @environment.should_receive(:running_instances_for_service).and_return([])
      end
      
      it "should not configure" do
        @agent_client.should_not_receive(:configure)
        @agent_service.configure_instance(@instance)
      end
      
      it "should return false" do
        @agent_service.configure_instance(@instance).should_not be_true
      end
    end

    context "if there are mod_cluster instances running" do
      before(:each) do
        other_instance = mock(Instance)
        other_instance.stub!(:public_dns).and_return('http://blah.ws')
        @environment.should_receive(:running_instances_for_service).and_return([other_instance])
      end

      it "should configure" do
        @agent_client.should_receive(:configure)
        @agent_service.configure_instance(@instance)
      end
      
      it "should return true" do
        @agent_service.configure_instance(@instance).should be_true
      end
    end

  end
end
