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

describe "/apps/new.html.haml" do
  include AppsHelper

  before(:each) do
    assigns[:app] = stub_model(App,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "renders new app form" do
    render

    response.should have_tag("form[action=?][method=post]", apps_path) do
      with_tag("input#app_name[name=?]", "app[name]")
      with_tag("textarea#app_description[name=?]", "app[description]")
    end
  end

  it "should have a cancel link" do
    render
    response.should have_tag("a[href=?]", apps_path)
  end
end
