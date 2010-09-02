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

describe App do

  it "should require a name attribute" do
    app = App.new
    app.save
    app.should have(1).error_on(:name)
  end

  it "should belong to a user" do
    App.new.should respond_to(:user)
  end

  it "should not be able to mass-assign user attribute" do
    app = App.new(:user => User.new)
    app.user.should be_nil
  end

  it "should have many app versions" do
    App.new.should respond_to(:app_versions)
  end

  it "should have many deployments" do
    App.new.should respond_to(:deployments)
  end
end
