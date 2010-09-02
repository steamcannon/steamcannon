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

describe EnvironmentImage do
  before(:each) do
    @valid_attributes = {
      :environment_id => 1,
      :image_id => 1,
      :hardware_profile => "value for hardware_profile",
      :num_instances => 1
    }
  end

  it "should create a new instance given valid attributes" do
    EnvironmentImage.create!(@valid_attributes)
  end

  it "should be able to deploy an instance" do
    instance = mock_model(Instance)
    Instance.should_receive(:deploy!).and_return(instance)
    image = Image.new(:name => "test_image")
    env_image = EnvironmentImage.new(:image => image,
                                     :hardware_profile => "m1-small",
                                     :num_instances => 1)
    env_image.start!(1)
  end
end
