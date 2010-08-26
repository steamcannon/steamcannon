require 'spec_helper'

describe Instance do
  before(:each) do
    cloud_instance = mock(:id => "i-12345",
                          :state => 'PENDING',
                          :public_addresses => [""])
    @cloud = mock(Cloud::Deltacloud)
    @cloud.stub!(:terminate)
    @cloud.stub!(:launch).and_return(cloud_instance)

    @image = mock_model(Image)
    @image.stub!(:cloud_id).and_return("ami-12345")
    @environment = mock_model(Environment)
    @environment.stub_chain(:user, :cloud).and_return(@cloud)

    @valid_attributes = {
      :environment => @environment,
      :image => @image,
      :name => "value for name",
      :cloud_id => "value for cloud_id",
      :hardware_profile => "value for hardware_profile",
      :public_dns => "value for public_dns"
    }
  end

  it "should create a new instance given valid attributes" do
    Instance.create!(@valid_attributes)
  end

  it "should belong to an environment" do
    Instance.new.should respond_to(:environment)
  end

  it "should belong to an image" do
    Instance.new.should respond_to(:image)
  end

  it "should be active after creation" do
    instance = Instance.create!(@valid_attributes)
    Instance.active.first.should eql(instance)
    Instance.inactive.count.should be(0)
  end

  it "should populate started_at after deploy!" do
    instance = Instance.deploy!(@image, @environment, "test", "small")
    instance.started_at.should_not be_nil
  end

  it "should populate started_by after deploy!" do
    login
    instance = Instance.deploy!(@image, @environment, "test", "small")
    instance.started_by.should be(@current_user.id)
  end

  it "should be status pending after deploy!" do
    instance = Instance.deploy!(@image, @environment, "test", "small")
    instance.status.should eql('pending')
  end

  it "should be status stopping after stop!" do
    instance = Instance.create!(@valid_attributes)
    instance.stop!
    instance.status.should eql('stopping')
  end

  it "should populate stopped_at after stop!" do
    instance = Instance.create!(@valid_attributes)
    instance.stop!
    instance.stopped_at.should_not be_nil
  end

  it "should populate stopped_by after stop!" do
    login
    instance = Instance.create!(@valid_attributes)
    instance.stop!
    instance.stopped_by.should be(@current_user.id)
  end

  it "should be inactive after stopped" do
    instance = Instance.create!(@valid_attributes)
    instance.update_attribute('status', 'stopped')
    Instance.inactive.first.should eql(instance)
    Instance.active.count.should be(0)
  end

  it "should generate certs on creation" do
    instance = Instance.create!(@valid_attributes)
    instance.server_key.should_not be_nil
    instance.server_cert.should_not be_nil
    instance.client_key.should_not be_nil
    instance.client_cert.should_not be_nil
  end

  it "should be running when status is running" do
    instance = Instance.new(:status => 'running')
    instance.should be_running
  end

  it "should be stopping when status is stopping" do
    instance = Instance.new(:status => 'stopping')
    instance.should be_stopping
  end

  it "should deploy with the correct image_id and hardware_profile" do
    @image.stub!(:cloud_id).and_return('ami-123')
    @cloud.should_receive(:launch).with("ami-123", "small")
    instance = Instance.deploy!(@image, @environment, "test", "small")
  end
end
