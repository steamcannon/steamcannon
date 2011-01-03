require 'spec_helper'

describe CloudProfile do
  before(:each) do
    @cloud_profile = Factory(:cloud_profile)
  end

  it { should belong_to :organization }
  it { should validate_presence_of :name }
  
  it "should encrypt the cloud password attribute before save" do
    @cloud_profile.stub!(:validate_cloud_credentials)
    @cloud_profile.password = "steamcannon"
    Certificate.should_receive :encrypt
    @cloud_profile.save
  end

  it "should save the encrypted cloud password" do
    @cloud_profile.stub!(:validate_cloud_credentials)
    @cloud_profile.password = "steamcannon"
    @cloud_profile.should_receive :crypted_password=
    @cloud_profile.save
  end

  it "should not save the encrypted cloud password if it hasn't changed" do
    @cloud_profile.provider_name = "somethingelse"
    @cloud_profile.should_not_receive :crypted_password=
    @cloud_profile.save
  end

  it "should provide an obfuscated version of the cloud password" do
    @cloud_profile.should respond_to :obfuscated_password
  end

  it "should completely obfuscate any cloud password with fewer than 6 characters" do
    @cloud_profile.password = "12345"
    @cloud_profile.obfuscated_password.should == "******"
  end

  it "should handle cloud passwords with fewer than 4 characters" do
    @cloud_profile.password = "123"
    @cloud_profile.obfuscated_password.should == "******"
  end

  it "should obfuscate all but the last for characters of any cloud password with more than 6 characters" do
    @cloud_profile.password = "1234567890"
    @cloud_profile.obfuscated_password.should == "******7890"
  end

  describe 'cloud' do
    it "should have a cloud object" do
      @cloud_profile.should respond_to(:cloud)
    end

    it "should pass cloud credentials and provider info through to cloud object" do
      @cloud_profile.username = 'user'
      @cloud_profile.password = 'password'
      @cloud_profile.cloud_name = 'driver x'
      @cloud_profile.provider_name = 'bf-egypt-1'
      Cloud::Deltacloud.should_receive(:new).with('user', 'password', 'driver x', 'bf-egypt-1')
      @cloud_profile.cloud
    end

    it "should cache the cloud instance" do
      Cloud::Deltacloud.should_receive(:new).once.and_return('not nil')
      @cloud_profile.cloud
      @cloud_profile.cloud
    end
  end
  
  describe "validate_cloud_credentials" do
    before(:each) do
      @cloud = mock('cloud')
      @cloud_profile.stub!(:cloud).and_return(@cloud)
    end

    it "should validate on save" do
      @cloud_profile.username = 'username'
      @cloud_profile.should_receive(:validate_cloud_credentials)
      @cloud_profile.save
    end

    it "should validate if username has changed" do
      @cloud_profile.username = 'username'
      @cloud.should_receive(:valid_credentials?)
      @cloud_profile.send(:validate_cloud_credentials)
    end

    it "should validate if password has changed" do
      @cloud_profile.password = 'password'
      @cloud.should_receive(:valid_credentials?)
      @cloud_profile.send(:validate_cloud_credentials)
    end

    it "shouldn't validate if username and password haven't changed" do
      @cloud.should_not_receive(:valid_credentials?)
      @cloud_profile.send(:validate_cloud_credentials)
    end

    it "shouldn't validate if the cloud raises an error" do
      @cloud_profile.username = 'username'
      @cloud.should_receive(:valid_credentials?).and_raise(Exception.new)
      @cloud_profile.send(:validate_cloud_credentials)
      @cloud_profile.errors.size.should be(1)
    end
    
    it "should add an error if invalid" do
      @cloud_profile.username = 'username'
      @cloud.should_receive(:valid_credentials?).and_return(false)
      @cloud_profile.send(:validate_cloud_credentials)
      @cloud_profile.errors.size.should be(1)
    end

    it "should not add an error if valid" do
      @cloud_profile.username = 'username'
      @cloud.should_receive(:valid_credentials?).and_return(true)
      @cloud_profile.send(:validate_cloud_credentials)
      @cloud_profile.errors.size.should be(0)
    end
  end

  it "should create cloud specific hacks" do
    cloud_profile = Factory.build(:cloud_profile)
    cloud_profile.should_receive(:cloud_name).and_return('ec2')
    Cloud::Specifics::Base.should_receive(:cloud_specifics).with('ec2', cloud_profile)
    cloud_profile.cloud_specific_hacks
  end

end

