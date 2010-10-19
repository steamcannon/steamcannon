require 'spec_helper'

describe AccountRequest do
  it { should validate_presence_of :email }

  it "should set the token after create" do
    @request = Factory(:account_request)
    @request.token.should_not be_nil
  end
end
