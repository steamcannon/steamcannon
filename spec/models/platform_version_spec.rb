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

describe PlatformVersion do
  before(:each) do
    @valid_attributes = {
      :version_number => "value for version_number",
      :platform_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    PlatformVersion.create!(@valid_attributes)
  end

  it "should have a version_number attribute" do
    PlatformVersion.new.should respond_to(:version_number)
  end

  it "should belong to a platform" do
    PlatformVersion.new.should respond_to(:platform)
  end

  it "should have many platform version images" do
    PlatformVersion.new.should respond_to(:platform_version_images)
  end

  it "should have many images" do
    PlatformVersion.new.should respond_to(:images)
  end

  it "should return the platform's name and its version as to_s" do
    platform = Platform.new(:name => "test platform")
    platform_version = PlatformVersion.new(:version_number => "0.1",
                                           :platform => platform)
    platform_version.to_s.should eql("test platform v0.1")
  end

  it "should not show the version if none exists" do
    platform = Platform.new(:name => "test platform")
    platform_version = PlatformVersion.new(:version_number => nil,
                                           :platform => platform)
    platform_version.to_s.should eql("test platform")
  end

end
