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
      @instance.stub_chain(:instance_services, :find).and_return(InstanceService)
      InstanceService.stub!(:find).with("1").and_return(@instance_service)
      controller.stub!(:log_ids).and_return([])
      controller.stub!(:tail_response).and_return({})
    end

    it "should be successful" do
      get :logs, :environment_id => 123, :instance_id => 234, :id => 1
      response.should be_success
    end
  end
end
