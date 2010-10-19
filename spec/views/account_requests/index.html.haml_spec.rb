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
