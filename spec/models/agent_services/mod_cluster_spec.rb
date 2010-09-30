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
    @service = Factory(:service)
    @environment = Factory(:environment)
    @agent_service = AgentServices::ModCluster.new(@service, @environment)
    @instance = Factory(:instance)
    @instance.services << @service
    Service.stub!(:by_name).and_return(Factory(:service))
    @jboss_instance = Factory(:instance)
    @jboss_instance_service = Factory.build(:instance_service)
    @jboss_instance_service.stub!(:configure)
    @jboss_instance.stub_chain(:instance_services, :find_by_service_id).and_return(@jboss_instance_service)
    @environment.stub!(:active_instances_for_service).and_return([@jboss_instance])
  end

  describe 'configure_instance' do
    it "should operate on active jboss instances" do
      @environment.should_receive(:active_instances_for_service).and_return([@jboss_instance])
      @agent_service.configure_instance(@instance)
    end

    it "should return true" do
      @agent_service.configure_instance(@instance).should == true
    end

    it "should configure the jboss instance_services" do
      @jboss_instance_service.should_receive(:configure)
      @agent_service.configure_instance(@instance)
    end
  end
end
