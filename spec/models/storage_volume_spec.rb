require 'spec_helper'

describe StorageVolume do
  it { should belong_to :environment_image }
  it { should belong_to :instance }
  it { should have_one :image }
  it { should have_one :environment }

  before(:each) do
    @storage_volume = Factory(:storage_volume)
    @cloud = mock('cloud')
    @storage_volume.stub!(:cloud).and_return(@cloud)
    ModelTask.stub!(:async)
  end

  describe 'prepare' do
    before(:each) do
      @instance = Factory(:instance)
    end

    it "should associate the instance" do
      @storage_volume.should_receive(:update_attribute).with(:instance, @instance)
      @storage_volume.prepare(@instance)
    end


    it "should try to create the volume as a task" do
      ModelTask.should_receive(:async).with(@storage_volume, :create_in_cloud)
      @storage_volume.prepare(@instance)
    end

  end

  describe "cloud_volume_exists?" do
    it "should be true if the cloud_volume is not nil" do
      @storage_volume.should_receive(:cloud_volume).and_return(mock('cloud volume'))
      @storage_volume.cloud_volume_exists?.should be_true
    end

    it "should be false if the cloud_volume is nil" do
      @storage_volume.should_receive(:cloud_volume).and_return(nil)
      @storage_volume.cloud_volume_exists?.should_not be_true
    end
  end

  describe 'cloud_volume_is_available?' do
    it "should be true if the cloud_volume exists with a status of 'available'" do
      cloud_volume = mock('cloud_volume')
      cloud_volume.should_receive(:state).and_return('AVAILABLE')
      @storage_volume.should_receive(:cloud_volume).at_least(1).and_return(cloud_volume)
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(true)
      @storage_volume.cloud_volume_is_available?.should be_true
    end

    it "should be false if the cloud_volume does not exist" do
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(false)
      @storage_volume.cloud_volume_is_available?.should_not be_true
    end

    it "should be false if the cloud volume has a status other than 'available'" do
      cloud_volume = mock('cloud_volume')
      cloud_volume.should_receive(:state).and_return('not avail')
      @storage_volume.should_receive(:cloud_volume).at_least(1).and_return(cloud_volume)
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(true)
      @storage_volume.cloud_volume_is_available?.should_not be_true
    end
  end

  describe 'cloud_volume' do
    it 'should return nil if the identifier is not set' do
      @storage_volume.volume_identifier = nil
      @storage_volume.cloud_volume.should be_nil
    end

    it "should lookup the volume from the cloud" do
      @storage_volume.volume_identifier = 'blah'
      @cloud.should_receive(:storage_volumes).with(:id => 'blah').and_return(['a volume'])
      @storage_volume.cloud_volume.should == 'a volume'
    end
  end

  describe 'create_in_cloud' do
    before(:each) do
      @instance = Factory(:instance)
      @instance.stub_chain(:cloud_specific_hacks, :default_realm).and_return('def realm')
      @storage_volume.stub!(:instance).and_return(@instance)
      @cloud_volume = mock('cloud_volume')
      @cloud_volume.stub!(:id).and_return("vol-1234")
      @image = Factory.build(:image, :storage_volume_capacity => '77')
      @storage_volume.stub!(:image).and_return(@image)
    end

    it "should return immediately if the cloud volume is available" do
      @storage_volume.should_receive(:cloud_volume_is_available?).and_return(true)
      @cloud.should_not_receive(:create_storage_volume)
      @storage_volume.send(:create_in_cloud)
    end

    it "should try to create" do
      @cloud.should_receive(:create_storage_volume).
        with(:realm => @instance.cloud_specific_hacks.default_realm,
             :capacity => '77').
        and_return(@cloud_volume)
      @storage_volume.send(:create_in_cloud)
    end

    it "should store the volume identifier" do
      @cloud.should_receive(:create_storage_volume).and_return(@cloud_volume)
      @storage_volume.send(:create_in_cloud)
      @storage_volume.volume_identifier.should == 'vol-1234'
    end
  end

  describe 'attach' do
    before(:each) do
      @instance = mock(Instance, :cloud_id => 'i-1234')
      @storage_volume.stub!(:instance).and_return(@instance)
      @cloud_volume = mock('cloud_volume')
      @storage_volume.stub!(:cloud_volume).and_return(@cloud_volume)
      @storage_volume.stub!(:cloud_volume_is_available?).and_return(true)
      @storage_volume.stub!(:cloud_volume_is_attached?).and_return(false)
      @image = mock(Image)
      @image.stub!(:storage_volume_device).and_return('/dev/sdh')
      @storage_volume.stub!(:image).and_return(@image)
    end

    it "should attach" do
      @cloud_volume.should_receive(:attach!).with(:instance_id => 'i-1234', :device => '/dev/sdh')
      @storage_volume.attach
    end

    it "should not attach if the cloud volume is not available" do
      @storage_volume.should_receive(:cloud_volume_is_available?).and_return(false)
      @cloud_volume.should_not_receive(:attach!)
      @storage_volume.attach
    end

    it "should return true if the volume is already attached" do
      @storage_volume.should_receive(:cloud_volume_is_available?).and_return(false)
      @storage_volume.should_receive(:cloud_volume_is_attached?).and_return(true)
      @cloud_volume.should_not_receive(:attach!)
      @storage_volume.attach.should be_true
    end
  end


  describe 'cloud_volume_is_attached?' do
    before(:each) do
      @cloud_volume = mock('cloud_volume')
      @storage_volume.stub!(:cloud_volume).and_return(@cloud_volume)
      @instance = mock(Instance, :cloud_id => 'i-1234')
      @storage_volume.stub!(:instance).and_return(@instance)
    end

    it "should be true if the cloud_volume exists, is in use, and is attached to the instance" do
      @cloud_volume.should_receive(:state).and_return('IN-USE')
      @cloud_volume.should_receive(:instance_id).and_return('i-1234')
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(true)
      @storage_volume.cloud_volume_is_attached?.should be_true
    end

    it "should be false if the cloud_volume does not exist" do
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(false)
      @storage_volume.cloud_volume_is_attached?.should_not be_true
    end

    it "should be false if the cloud volume has a status other than 'in-use'" do
      @cloud_volume.should_receive(:state).and_return('not avail')
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(true)
      @storage_volume.cloud_volume_is_attached?.should_not be_true
    end

    it "should be false if the volume is attached to another instance" do
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(true)
      @cloud_volume.should_receive(:state).and_return('IN-USE')
      @cloud_volume.should_receive(:instance_id).and_return('i-1235')
      @storage_volume.cloud_volume_is_attached?.should_not be_true
    end
  end


  context 'destroy' do
    before(:each) do
      @cloud_volume = mock('cloud_volume')
    end

    describe '#destroy' do
      it "should set the pending_destroy flag" do
        @storage_volume.destroy
        @storage_volume.reload.should be_pending_destroy
      end
    end

    describe "#real_destroy" do
      context 'when the cloud volume exists' do
        before(:each) do
          @storage_volume.stub!(:cloud_volume_exists?).and_return(true)
        end

        it "should destroy from deltacloud on destroy if the cloud volume is available" do
          @storage_volume.stub!(:cloud_volume_is_available?).and_return(true)
          @storage_volume.stub!(:cloud_volume).and_return(@cloud_volume)
          @cloud_volume.should_receive(:destroy!)
          @storage_volume.real_destroy
        end

        it "should not destroy the cloud volume if it is not available" do
          @storage_volume.stub!(:cloud_volume_is_available?).and_return(false)
          @storage_volume.stub!(:cloud_volume).and_return(@cloud_volume)
          @cloud_volume.should_not_receive(:destroy!)
          @storage_volume.real_destroy
        end

        it "should delete the storage_volume if the cloud volume is in a state to be deleted" do
          @storage_volume.stub!(:cloud_volume_is_available?).and_return(true)
          @storage_volume.stub!(:cloud_volume).and_return(@cloud_volume)
          @cloud_volume.should_receive(:destroy!)
          @storage_volume.real_destroy
          lambda { @storage_volume.reload }.should raise_error(ActiveRecord::RecordNotFound)
        end

        it "should not delete the storage_volume if the cloud volume is not in a state to be deleted" do
          @storage_volume.stub!(:cloud_volume_is_available?).and_return(false)
          @storage_volume.stub!(:cloud_volume).and_return(@cloud_volume)
          @cloud_volume.should_not_receive(:destroy!)
          @storage_volume.real_destroy
          lambda { @storage_volume.reload }.should_not raise_error
        end
      end
    end
  end
end
