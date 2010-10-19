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
