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

describe "/environments/index.html.haml" do
  include EnvironmentsHelper

  before(:each) do
    assigns[:environments] = [
      stub_model(Environment,
                 :name => "value for name"
      ),
      stub_model(Environment,
                 :name => "value for name"
      )
    ]
  end

  it "renders a list of environments" do
    render
    response.should have_tag("div.environment_name", "value for name".to_s, 2)
  end

  it "renders a link to create a new environment" do
    render
    response.should have_tag("a[href=?]", new_environment_path)
  end
end
