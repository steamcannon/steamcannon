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

describe "/environments/edit.html.haml" do
  include EnvironmentsHelper

  before(:each) do
    assigns[:environment] =
      stub_model(Environment,
                 :new_record? => false,
                 :id => 1,
                 :name => "value for name",
                 :platform => stub_model(Platform,
                                         :platform_versions => []),
                 :cloud_profile => stub_model(CloudProfile,
                                              :name_with_details => 'name'))
    @controller.template.stub!(:hardware_profile_options).and_return([])
  end

  it "renders edit environment form" do
    render

    response.should have_tag("form[action=?][method=post]", environment_path(assigns[:environment])) do
      with_tag("input#environment_name[name=?]", "environment[name]")
      with_tag("select#environment_platform_version_id[name=?]",
               "environment[platform_version_id]")
    end
  end
end
