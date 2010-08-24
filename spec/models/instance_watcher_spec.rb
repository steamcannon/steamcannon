require 'spec_helper'

describe InstanceWatcher do
  before(:each) do
    @instance_watcher = InstanceWatcher.new
  end

  it "should update pending and stopping instances" do
    @instance_watcher.should_receive(:update_pending)
    @instance_watcher.should_receive(:update_stopping)
    @instance_watcher.run
  end

  it "should update each pending instance from cloud" do
    instance = mock_model(Instance)
    Instance.stub!(:pending).and_return([instance])
    @instance_watcher.should_receive(:update_attributes_from_cloud).
      with(instance)
    @instance_watcher.update_pending
  end

  it "should update each stopping instance from cloud" do
    instance = mock_model(Instance)
    Instance.stub!(:stopping).and_return([instance])
    @instance_watcher.should_receive(:update_attributes_from_cloud).
      with(instance)
    @instance_watcher.update_stopping
  end

  describe "update attributes from cloud" do
    before(:each) do
      @cloud_instance = mock(Object,
                             :state => '',
                             :public_addresses => [])
      @instance = mock_model(Instance,
                             :save! => true,
                             :cloud_id => 'i-12345',
                             :status= => nil,
                             :public_dns= => nil)
      @instance.stub_chain(:cloud, :instance).and_return(@cloud_instance)
    end

    it "should look up status from cloud" do
      cloud = mock(Object)
      cloud.should_receive(:instance).with('i-12345').and_return(@cloud_instance)
      @instance.stub!(:cloud).and_return(cloud)
      @instance_watcher.update_attributes_from_cloud(@instance)
    end

    it "should set instance to pending when pending in cloud" do
      @cloud_instance.stub!(:state).and_return('pending')
      @instance.should_receive(:status=).with('pending')
      @instance_watcher.update_attributes_from_cloud(@instance)
    end

    it "should set instance to running when running in cloud" do
      @cloud_instance.stub!(:state).and_return('running')
      @instance.should_receive(:status=).with('running')
      @instance_watcher.update_attributes_from_cloud(@instance)
    end

    it "should set instance to stopping when stopping in cloud" do
      @cloud_instance.stub!(:state).and_return('stopping')
      @instance.should_receive(:status=).with('stopping')
      @instance_watcher.update_attributes_from_cloud(@instance)
    end

    it "should set instance to stopped when terminated in cloud" do
      @cloud_instance.stub!(:state).and_return('terminated')
      @instance.should_receive(:status=).with('stopped')
      @instance_watcher.update_attributes_from_cloud(@instance)
    end

    it "should set instance public_dns to first public cloud dns" do
      @cloud_instance.stub!(:public_addresses).and_return(['abc-123'])
      @instance.should_receive(:public_dns=).with('abc-123')
      @instance_watcher.update_attributes_from_cloud(@instance)
    end

    it "should save instance after updating from cloud" do
      @instance.should_receive(:save!)
      @instance_watcher.update_attributes_from_cloud(@instance)
    end
  end

end
