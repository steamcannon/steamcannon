require 'spec_helper'

describe Cloud::Deltacloud do
  before(:each) do
    @deltacloud = Cloud::Deltacloud.new('abc', '123')
  end

  describe "client" do
    before(:each) do
      APP_CONFIG ||= {}
    end

    it "should create with right credentials and url" do
      APP_CONFIG['deltacloud_url'] = 'url'
      DeltaCloud.should_receive(:new).with('abc', '123', 'url')
      @deltacloud.client
    end

    it "should only initialize once" do
      DeltaCloud.should_receive(:new).once.and_return(Object.new)
      @deltacloud.client
      @deltacloud.client
    end
  end

  it "should return user data in a specific format" do
    # Base64-encoded user data taken from old yaml-based code
    # for a user "abc", password "123", bucket "default"
    expected_data = "YWNjZXNzX2tleTogYWJjCnNlY3JldF9hY2Nlc3Nfa2V5OiAxMjMKYnVja2V0\nOiBkZWZhdWx0\n"
    user_data = @deltacloud.user_data("default")
    user_data.should eql(expected_data)
  end
end
