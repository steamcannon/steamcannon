require 'spec_helper'

describe InstanceTask do
  before(:each) do
    @instance_task = InstanceTask.new
    @payload = { :instance_id => 123 }
    @instance = mock_model(Instance)
    Instance.stub!(:find).and_return(@instance)
  end

  describe "launch" do
    before(:each) do
      @instance.stub!(:start!)
    end

    it "should find instance by instance_id payload" do
      Instance.should_receive(:find).with(123).and_return(@instance)
      @instance_task.launch_instance(@payload)
    end

    it "should start instance" do
      @instance.should_receive(:start!)
      @instance_task.launch_instance(@payload)
    end
  end

  describe "stop" do
    before(:each) do
      @instance.stub!(:terminate!)
    end

    it "should find instance by instance_id payload" do
      Instance.should_receive(:find).with(123).and_return(@instance)
      @instance_task.stop_instance(@payload)
    end

    it "should terminate instance" do
      @instance.should_receive(:terminate!)
      @instance_task.stop_instance(@payload)
    end
  end
end
