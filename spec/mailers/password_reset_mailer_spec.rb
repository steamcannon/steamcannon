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

describe "PasswordResetMailer" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "password_reset_instructions" do
    before(:each) do
      @sender = 'from@example.com'
      @user   = mock_model(User)
      @user.stub!(:perishable_token).and_return("123")
      @user.stub!(:email).and_return('foo@bar.com')
      @email  = PasswordResetMailer.create_password_reset_instructions(@user, @sender)
    end

    it "should be to the user's email address" do
      @email.should deliver_to(@user.email)
    end

    it "should be from the sender" do
      @email.should deliver_from(@sender)
    end

    it "should include the password reset token in the url" do
      @email.should have_body_text("http://try.steamcannon.org/password_resets/#{@user.perishable_token}/edit")
    end
  end

end
