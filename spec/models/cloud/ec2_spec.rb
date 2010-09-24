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

describe Cloud::Ec2 do
  before(:each) do
    @instance = Factory.build(:instance)
    @ec2 = Cloud::Ec2.new(@instance)
  end

  describe "multicast_config" do
    before(:each) do
      @ec2.stub!(:pre_signed_put_url).and_return('put_url')
      @ec2.stub!(:pre_signed_delete_url).and_return('delete_url')
    end

    it "should generate put_url" do
      @ec2.should_receive(:pre_signed_put_url)
      @ec2.multicast_config
    end

    it "should generate delete_url" do
      @ec2.should_receive(:pre_signed_delete_url)
      @ec2.multicast_config
    end

    it "should return put and delete urls" do
      expected = {
        :s3_ping => {
          :pre_signed_put_url => 'put_url',
          :pre_signed_delete_url => 'delete_url'
        }
      }
      @ec2.multicast_config.should == expected
    end
  end
end
