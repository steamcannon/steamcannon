require 'spec_helper'

describe "AccountRequestMailer" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "invitation" do
    before(:each) do
      @host = 'localhost:1234'
      @sender = 'from@example.com'
      @to = 'to@example.com'
      @token = 'token123'
      @email = AccountRequestMailer.create_invitation(@host, @sender, @to, @token)
    end

    it "should be to the given to" do
      @email.should deliver_to(@to)
    end

    it "should be from the sender" do
      @email.should deliver_from(@sender)
    end

    it "should include the host and token in the url" do
      @email.should have_body_text("http://#{@host}/users/new?token=#{@token}")
    end
  end
end
