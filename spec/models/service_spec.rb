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

describe Service do
  before(:each) do
    @service = Factory(:service)
  end

  it { should have_many :artifacts }
  it { should have_many :instance_services}
  it { should have_many :instances }
  
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe "deploy" do
    before(:each) do
      @service = Factory.build(:service)
      @environment = Factory.build(:environment)
      @agent_service = AgentServices::DefaultService.new(@service, @environment)
    end
    
    it "should delegate to the agent_service" do
      @agent_service.should_receive(:deploy).with([])
      AgentServices::DefaultService.should_receive(:instance_for_service).with(@service, @environment).and_return(@agent_service)
      @service.deploy(@environment, [])
    end

    it "should limit to deployments for itself" do
      @service.should_receive(:filter_deployments).with([]).and_return([])
      @service.deploy(@environment, [])
    end
  end

  describe 'filter_deployments' do
    before(:each) do
      @service = Factory.build(:service)
      @another_service = Factory.build(:service)
      
      @deployment_one = mock(Deployment)
      @deployment_one.stub!(:service).and_return(@service)
      @deployment_two = mock(Deployment)
      @deployment_two.stub!(:service).and_return(@another_service)
    end
    
    it "should remove deployments for other services" do
      @service.send(:filter_deployments, [@deployment_one, @deployment_two]).should == [@deployment_one]
    end
  end
end
