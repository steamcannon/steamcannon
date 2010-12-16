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

describe EnvironmentsHelper do

  it "should convert a list of PlatformVersions to select options" do
    pv1 = mock_model(PlatformVersion, :to_s => "pv1", :id => "1")
    pv2 = mock_model(PlatformVersion, :to_s => "pv2", :id => "2")
    options = helper.platform_version_options([pv1, pv2])
    options.size.should be(2)
    options.first.should eql(["pv1", "1"])
    options.last.should eql(["pv2", "2"])
  end

  it "should retrieve hardware profiles from cloud" do
    helper.stub_chain(:current_user, :cloud, :attempt).and_return(['small'])
    helper.hardware_profile_options.should eql(['small'])
  end

end
