#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

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
