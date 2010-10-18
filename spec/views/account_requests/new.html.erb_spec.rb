require 'spec_helper'

describe "/account_requests/new.html.erb" do
  include AccountRequestsHelper

  before(:each) do
    assigns[:account_request] = stub_model(AccountRequest,
      :new_record? => true,
      :email => "value for email",
      :reason => "value for reason"
    )
  end

  it "renders new account_request form" do
    render

    response.should have_tag("form[action=?][method=post]", account_requests_path) do
      with_tag("input#account_request_email[name=?]", "account_request[email]")
      with_tag("textarea#account_request_reason[name=?]", "account_request[reason]")
    end
  end
end
