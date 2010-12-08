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
    @environment = stub_model(Environment)
    assigns[:environment] = @environment
    @environment.stub_chain(:user, :cloud, :name).and_return('the-cloud')
    @environment.stub_chain(:user, :cloud, :hardware_profiles_url).and_return('http://test.server/hardware_profiles')
    @environment.stub_chain(:user, :cloud, :realms_url).and_return('http://test.server/realms')
    @environment.stub_chain(:user, :cloud, :instance_states_url).and_return('http://test.server/instance_states')
    @environment.stub_chain(:user, :cloud, :images_url).and_return('http://test.server/images')
    @environment.stub_chain(:user, :cloud, :instances_url).and_return('http://test.server/instances')
  end

  it "renders the DeltaCloud API endpoint for the enironment" do
    @environment.user.cloud.should_receive(:name).and_return('the-cloud')
    render
    response.should have_tag("api[driver=?]", 'the-cloud') do
      with_tag("link[rel=?][href=?][proxy-for=?]", "hardware_profiles", hardware_profiles_url, @environment.cloud.hardware_profiles_url)
      with_tag("link[rel=?][href=?][proxy-for=?]", "instance_states", instance_states_environment_url(@environment), @environment.cloud.instance_states_url)
      with_tag("link[rel=?][href=?][proxy-for=?]", "realms", realms_url, @environment.cloud.realms_url)
      with_tag("link[rel=?][href=?][proxy-for=?]", "images", environment_images_url(@environment), @environment.cloud.images_url)
      with_tag("link[rel=?][href=?][proxy-for=?]", "instances", environment_instances_url(@environment), @environment.cloud.instances_url)
    end
  end
end
