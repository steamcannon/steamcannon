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
  end
  
  describe 'prepare' do
    before(:each) do
      @instance = Factory(:instance)
    end
    
    it "should associate the instance" do
      @storage_volume.should_receive(:update_attribute).with(:instance, @instance)
      @storage_volume.stub!(:create_in_cloud)
      @storage_volume.prepare(@instance)
    end


    it "should try to create the volume if the cloud_volume is unavailable" do
      @storage_volume.should_receive(:cloud_volume_is_available?).and_return(false)
      @storage_volume.should_receive(:create_in_cloud)
      @storage_volume.prepare(@instance)
    end
    
  end
  
  describe 'cloud_volume_is_available?' do
    it "should be true if the volume_identifier is set and the cloud_volume exists, with a status of 'available'" do
      @storage_volume.volume_identifier = 'blah'
      cloud_volume = mock('cloud_volume')
      cloud_volume.should_receive(:state).and_return('AVAILABLE')
      @storage_volume.should_receive(:cloud_volume).at_least(1).and_return(cloud_volume)
      @storage_volume.cloud_volume_is_available?.should be_true
    end

    it "should be false if the volume_identifier is not set" do
      @storage_volume.volume_identifier = nil
      @storage_volume.cloud_volume_is_available?.should_not be_true
    end

    it "should be false if the cloud_volume does not exist" do
      @storage_volume.volume_identifier = 'blah'
      @storage_volume.should_receive(:cloud_volume).and_return(nil)
      @storage_volume.cloud_volume_is_available?.should_not be_true
    end

    it "should be false if the cloud volume has a status other than 'available'" do
      @storage_volume.volume_identifier = 'blah'
      cloud_volume = mock('cloud_volume')
      cloud_volume.should_receive(:state).and_return('not avail')
      @storage_volume.should_receive(:cloud_volume).at_least(1).and_return(cloud_volume)
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
      @image = mock(Image)
      @image.stub!(:storage_volume_device).and_return('/dev/sdh')
      @storage_volume.stub!(:image).and_return(@image)
    end
    
    it "should attach" do
      @cloud_volume.should_receive(:attach!).with(:instance_id => 'i-1234', :device => '/dev/sdh')
      @storage_volume.attach
    end
  end
  
  it "should destroy from deltacloud on destroy"
  
end
