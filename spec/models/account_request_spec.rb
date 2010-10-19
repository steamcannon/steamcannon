require 'spec_helper'

describe AccountRequest do
  it { should validate_presence_of :email }

  it "should set the token after create" do
    @request = Factory(:account_request)
    @request.token.should_not be_nil
  end

  describe 'send_invitation' do
    before(:each) do
      @host = 'some.example.com'
      @from = 'from@example.com'
      @account_request = Factory(:account_request)
    end

    it "should send asynchronously" do
      ModelTask.should_receive(:async).with(@account_request, :_send_invitation, @host, @from)
      @account_request.send_invitation(@host, @from)
    end
    
    it "should mark the account_request as invited" do
      @account_request.should_receive(:invite!)
      @account_request.send_invitation(@host, @from)
    end

    it "actual send method should send the email with the proper arguments" do
      AccountRequestMailer.should_receive(:deliver_invitation).with(@host, @from, @account_request.email, @account_request.token)
      @account_request.send(:_send_invitation, @host, @from)
    end

  end
end

