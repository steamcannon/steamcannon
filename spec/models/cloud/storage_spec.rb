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

describe Cloud::Storage do
  before(:each) do
    @storage = Object.new
    @storage.extend(Cloud::Storage)

    @user = Factory.build(:user)
  end

  it "should find user from artifact" do
    artifact = Factory.build(:artifact)
    artifact.should_receive(:user).and_return(@user)
    artifact_version = Factory.build(:artifact_version)
    artifact_version.should_receive(:artifact).and_return(artifact)
    @storage.should_receive(:instance).and_return(artifact_version)
    @storage.user.should == @user
  end

  it "should find cloud_name from user's cloud" do
    cloud = mock(Object, :name => 'cloud_name')
    @user.should_receive(:cloud).and_return(cloud)
    @storage.should_receive(:user).and_return(@user)
    @storage.cloud_name.should == 'cloud_name'
  end

  describe "cloud_storage" do
    before(:each) do
      @storage.stub!(:user).and_return(@user)
      class Cloud::Storage::TestStorage; end
      @storage.stub!(:cloud_name).and_return('test')
    end

    it "should convert cloud name to storage class" do
      Cloud::Storage::TestStorage.should_receive(:new)
      @storage.cloud_storage
    end

    it "should initialize storage class with cloud credentials" do
      @user.cloud_username = 'user'
      @user.cloud_password = 'pass'
      Cloud::Storage::TestStorage.should_receive(:new).with('user', 'pass')
      @storage.cloud_storage
    end
  end

  ["ec2", "mock", "virtualbox"].each do |cloud|
    describe "#{cloud} storage" do
      before(:each) do
        @user.cloud_username = 'user'
        @user.cloud_password = 'pass'
        @storage.stub!(:user).and_return(@user)
        @storage.stub!(:cloud_name).and_return(cloud)
      end

      it "should initialize without error" do
        @storage.cloud_storage
      end

      it "should have an exists? method" do
        @storage.cloud_storage.should respond_to(:exists?)
      end

      it "should have a to_file method" do
        @storage.cloud_storage.should respond_to(:to_file)
      end

      it "should have a write method" do
        @storage.cloud_storage.should respond_to(:write)
      end

      it "should have a delete method" do
        @storage.cloud_storage.should respond_to(:delete)
      end
    end
  end
end
