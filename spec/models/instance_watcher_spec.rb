require 'spec_helper'

describe InstanceWatcher do
  before(:each) do
    @instance_watcher = InstanceWatcher.new
  end

  it "should update starting and terminating instances" do
    @instance_watcher.should_receive(:update_starting)
    @instance_watcher.should_receive(:update_terminating)
    @instance_watcher.run
  end

  it "should transition each starting instance to running" do
    instance = mock_model(Instance)
    instance.should_receive(:run!)
    Instance.stub!(:starting).and_return([instance])
    @instance_watcher.update_starting
  end

  it "should transition each terminating instance to stopped" do
    instance = mock_model(Instance)
    instance.should_receive(:stopped!)
    Instance.stub!(:terminating).and_return([instance])
    @instance_watcher.update_terminating
  end
end
