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

describe Cloud::Deltacloud do
  before(:each) do
    @deltacloud = Cloud::Deltacloud.new('abc', '123')
  end

  describe "launch" do
    before(:each) do
      @client = mock(Object)
      @deltacloud.stub!(:client).and_return(@client)
      @deltacloud.stub!(:user_data).and_return('')
    end

    it "should create instance in the cloud" do
      @client.should_receive(:create_instance).
        with('ami-123',
             :hardware_profile => 'm1.small')
      @deltacloud.launch('ami-123', :hardware_profile => 'm1.small')
    end
  end

  describe "hardware profiles" do
    before(:each) do
      @client = mock(Object,
                     :hardware_profiles => [])
      @deltacloud.stub!(:client).and_return(@client)
    end

    it "should fetch from cloud" do
      @client.should_receive(:hardware_profiles)
      @deltacloud.hardware_profiles
    end

    it "should only fetch once" do
      @client.should_receive(:hardware_profiles).once.and_return([])
      @deltacloud.hardware_profiles
      @deltacloud.hardware_profiles
    end

    it "should only return profile names" do
      profile = mock(Object, :name => "small")
      @client.should_receive(:hardware_profiles).and_return([profile])
      @deltacloud.hardware_profiles.should eql(["small"])
    end
  end

  describe "client" do
    before(:each) do
      APP_CONFIG ||= {}
    end

    it "should create with right credentials and url" do
      APP_CONFIG['deltacloud_url'] = 'url'
      DeltaCloud.should_receive(:new).with('abc', '123', 'url')
      @deltacloud.client
    end

    it "should only initialize once" do
      DeltaCloud.should_receive(:new).once.and_return(Object.new)
      @deltacloud.client
      @deltacloud.client
    end
  end
end
