require 'spec_helper'

describe EnvironmentWatcher do
  before(:each) do
    @environment_watcher = EnvironmentWatcher.new
  end

  it "should update starting and stopping environments" do
    @environment_watcher.should_receive(:update_starting)
    @environment_watcher.should_receive(:update_stopping)
    @environment_watcher.run
  end

  it "should transition each starting environment to running" do
    environment = mock_model(Environment)
    environment.should_receive(:run!)
    Environment.stub!(:starting).and_return([environment])
    @environment_watcher.update_starting
  end

  it "should transition each stopping environment to stopped" do
    environment = mock_model(Environment)
    environment.should_receive(:stopped!)
    Environment.stub!(:stopping).and_return([environment])
    @environment_watcher.update_stopping
  end
end
