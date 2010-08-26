require 'spec_helper'

describe EnvironmentsHelper do

  it "should convert a list of PlatformVersions to select options" do
    pv1 = mock_model(PlatformVersion, :to_s => "pv1", :id => "1")
    pv2 = mock_model(PlatformVersion, :to_s => "pv2", :id => "2")
    options = helper.platform_version_options([pv1, pv2])
    options.size.should be(2)
    options.first.should eql(["pv1", "1"])
    options.last.should eql(["pv2", "2"])
  end

  it "should retrieve hardware profiles from cloud" do
    helper.stub_chain(:current_user, :cloud, :hardware_profiles).and_return(['small'])
    helper.hardware_profile_options.should eql(['small'])
  end

end
