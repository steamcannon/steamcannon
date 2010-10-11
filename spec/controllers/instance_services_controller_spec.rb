require 'spec_helper'

describe InstanceServicesController do
  before(:each) do
    login
    @current_user.stub!(:environments).and_return(Environment)
    @current_user.stub!(:instances).and_return(Instance)
  end

  describe "GET logs" do
    before(:each) do
      @environment = Factory(:environment)
      @instance = Factory(:instance)
      @instance_service = Factory(:instance_service)
      Environment.stub!(:find).with("123").and_return(@environment)
      Instance.stub!(:find).with("234").and_return(@instance)
      @instance.stub!(:instance_services).and_return(InstanceService)
      InstanceService.stub!(:find).with("1").and_return(@instance_service)
    end

    it "should be successful" do
      controller.stub!(:log_ids).and_return([])
      get :logs, :environment_id => 123, :instance_id => 234, :id => 1
      response.should be_success
    end

    it "should retrieve valid log ids from agent client" do
      agent_client = mock('agent_client')
      @instance_service.should_receive(:agent_client).and_return(agent_client)
      agent_client.should_receive(:logs).and_return(['log_id'])
      get :logs, :environment_id => 123, :instance_id => 234, :id => 1
    end

    context "js format" do
      it "should be successful" do
        controller.stub!(:tail_response).and_return({})
        xhr :get, :logs, :environment_id => 123, :instance_id => 234, :id => 1
        response.should be_success
      end

      it "should generate tail response" do
        controller.should_receive(:tail_response).and_return({:offset => 0})
        xhr :get, :logs, :environment_id => 123, :instance_id => 234, :id => 1
      end

      it "should retrieve tail response from agent client" do
        agent_client = mock('agent_client')
        @instance_service.should_receive(:agent_client).and_return(agent_client)
        agent_client.should_receive(:fetch_log).and_return({})
        xhr :get, :logs, :environment_id => 123, :instance_id => 234, :id => 1
      end
    end
  end
end
