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

describe "/environments/deltacloud.xml.haml" do
  include EnvironmentsHelper

  before(:each) do
    assigns[:environment] = stub_model(Environment)
    assigns[:environment].stub_chain(:user, :cloud, :name).and_return('the-cloud')
  end

  it "renders the DeltaCloud API endpoint for the enironment" do
    assigns[:environment].user.cloud.should_receive(:name).and_return('the-cloud')
    render
    response.should have_tag("api[driver=?]", 'the-cloud') do
      with_tag("link[rel=?][href=?]", "hardware_profiles", environment_hardware_profiles_url(assigns[:environment]))
      with_tag("link[rel=?][href=?]", "instance_states", instance_states_environment_url(assigns[:environment]))
      with_tag("link[rel=?][href=?]", "realms", environment_realms_url(assigns[:environment]))
      with_tag("link[rel=?][href=?]", "images", environment_images_url(assigns[:environment]))
      with_tag("link[rel=?][href=?]", "instances", environment_instances_url(assigns[:environment]))
    end
  end
end
