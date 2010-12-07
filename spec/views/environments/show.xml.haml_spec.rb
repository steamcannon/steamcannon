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

describe "/environments/show.xml.haml" do
  include EnvironmentsHelper

  before(:each) do
    @environment = stub_model(Environment)
    assigns[:environment] = @environment
    @environment.stub_chain(:user, :email).and_return('joe@smith.com')
    @environment.stub_chain(:user, :cloud, :name).and_return('the-cloud')
  end

  it "renders the DeltaCloud API endpoint url for the environment" do
    render
    response.should have_tag("environment[href=?]", environment_url(@environment)) do
      with_tag("link[href=?]", deltacloud_environment_url(@environment))
    end
  end

  it "renders the environment attributes" do
    render
    response.should have_tag("environment[href=?]", environment_url(@environment)) do
      with_tag("name", @environment.name)
      with_tag("owner", @environment.user.email)
      with_tag("created", @environment.created_at)
      with_tag("updated", @environment.updated_at)
      with_tag("current_state", @environment.current_state)
      with_tag("preserve_storage_volumes", @environment.preserve_storage_volumes)
    end
  end
end
