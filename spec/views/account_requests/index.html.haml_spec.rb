require 'spec_helper'

describe "/account_requests/index.html.haml" do
  include AccountRequestsHelper

  before(:each) do
    assigns[:account_requests] =
      [
       stub_model(AccountRequest,
                  :email => "value for email",
                  :reason => "value for reason",
                  :created_at => Time.now
                  ),
       stub_model(AccountRequest,
                  :email => "value for email",
                  :reason => "value for reason",
                  :created_at => Time.now

                  )
      ]
  end

  it "renders a list of account_requests" do
    render
    response.should have_tag("tr>td", "value for email".to_s, 2)
    response.should have_tag("tr>td", "value for reason".to_s, 2)
  end
end
