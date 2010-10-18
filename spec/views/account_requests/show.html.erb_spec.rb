require 'spec_helper'

describe "/account_requests/show.html.erb" do
  include AccountRequestsHelper
  before(:each) do
    assigns[:account_request] = @account_request = stub_model(AccountRequest,
      :email => "value for email",
      :reason => "value for reason"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ email/)
    response.should have_text(/value\ for\ reason/)
  end
end
