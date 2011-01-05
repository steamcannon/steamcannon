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

describe "/environments/show.html.haml" do
  include EnvironmentsHelper

  before(:each) do
    @environment = assigns[:environment] = stub_model(Environment, :name=>'env-1')
    @environment.stub_chain(:platform_version, :platform, :name).and_return('the platform')
    @environment.stub_chain(:cloud_profile, :name_with_details).and_return('cloud profile w/details')
    assigns[:deployments] = mock
    assigns[:deployments].stub(:values).and_return([])
  end

  it "provides a link for a new deployment" do
    render
    response.should have_tag("div.actions") do
      with_tag("a[href=?]", new_environment_deployment_path(@environment))
    end
  end

end

