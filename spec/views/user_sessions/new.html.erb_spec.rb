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

describe "/user_sessions/new" do
  before(:each) do
    @user_session = mock_model(UserSession)
    assigns[:user_session] = @user_session
  end

  it "should display the login form" do
    @user_session.should_receive(:email).and_return(nil)
    @user_session.should_receive(:password).and_return(nil)
    render 'user_sessions/new'
    response.should have_tag('form[action=?]', user_session_path)
  end

  it "should display email if given" do
    @user_session.should_receive(:email).and_return("my_email@test.com")
    @user_session.should_receive(:password).and_return(nil)
    render 'user_sessions/new'
    response.should have_tag('input[value=?]', "my_email@test.com")
  end
end
