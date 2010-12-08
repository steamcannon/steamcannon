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

describe AccountRequest do
  it { should belong_to :organization }
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

  describe "send_request_notification" do
    before(:each) do
      @host = 'some.example.com'
      @to = 'from@example.com'
      @account_request = Factory(:account_request)
    end

    it "should send asynchronously" do
      ModelTask.should_receive(:async).with(@account_request, :_send_request_notification, @host, @to)
      @account_request.send_request_notification(@host, @to)
    end

    it "actual send method should send the email with the proper arguments" do
      AccountRequestMailer.should_receive(:deliver_request_notification).with(@host, @account_request, @to)
      @account_request.send(:_send_request_notification, @host, @to)
    end

  end

end

