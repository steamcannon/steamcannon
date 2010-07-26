require 'spec_helper'

describe EnvironmentsHelper do

  #Delete this example and add some real ones or delete this file
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(EnvironmentsHelper)
  end

  it "should convert a list of PlatformVersions to select options" do
    pv1 = mock_model(PlatformVersion, :to_s => "pv1", :id => "1")
    pv2 = mock_model(PlatformVersion, :to_s => "pv2", :id => "2")
    options = helper.platform_version_options([pv1, pv2])
    options.size.should be(2)
    options.first.should eql(["pv1", "1"])
    options.last.should eql(["pv2", "2"])
  end

end
