require 'spec_helper'

describe InstanceWatcher do
  before(:each) do
    @instance_watcher = InstanceWatcher.new
  end

  it "should update booting and terminating instances" do
    @instance_watcher.should_receive(:update_booting)
    @instance_watcher.should_receive(:update_terminating)
    @instance_watcher.run
  end

  it "should transition each booting instance to running" do
    instance = mock_model(Instance)
    instance.should_receive(:run!)
    Instance.stub!(:booting).and_return([instance])
    @instance_watcher.update_booting
  end

  it "should transition each terminating instance to stopped" do
    instance = mock_model(Instance)
    instance.should_receive(:stopped!)
    Instance.stub!(:terminating).and_return([instance])
    @instance_watcher.update_terminating
  end
end
