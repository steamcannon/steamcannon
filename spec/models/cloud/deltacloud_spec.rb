require 'spec_helper'

describe Cloud::Deltacloud do
  it "should return user data in a specific format" do
    # Base64-encoded user data taken from old yaml-based code
    # for a user "abc", password "123", bucket "default"
    expected_data = "YWNjZXNzX2tleTogYWJjCnNlY3JldF9hY2Nlc3Nfa2V5OiAxMjMKYnVja2V0\nOiBkZWZhdWx0\n"
    deltacloud = Cloud::Deltacloud.new("abc", "123")
    user_data = deltacloud.user_data("default")
    user_data.should eql(expected_data)
  end
end
