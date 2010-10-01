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

describe Image do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :cloud_id => "value for cloud_id",
    }
  end

  it { should have_many :platform_versions }
  it { should have_many :instances }
  it { should have_many :image_services }
  it { should have_many :services }
  
  it "should create a new instance given valid attributes" do
    Image.create!(@valid_attributes)
  end

  it "should have a name attribute" do
    Image.new.should respond_to(:name)
  end

  it "should have a cloud_id attribute" do
    Image.new.should respond_to(:cloud_id)
  end

end
