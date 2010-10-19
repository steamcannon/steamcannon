require 'spec_helper'

describe "/account_requests/edit.html.haml" do
  include AccountRequestsHelper

  before(:each) do
    assigns[:account_request] = @account_request = stub_model(AccountRequest,
      :new_record? => false,
      :email => "value for email",
      :reason => "value for reason"
    )
  end

  it "renders the edit account_request form" do
    render

    response.should have_tag("form[action=#{account_request_path(@account_request)}][method=post]") do
      with_tag('input#account_request_email[name=?]', "account_request[email]")
      with_tag('textarea#account_request_reason[name=?]', "account_request[reason]")
    end
  end
end
