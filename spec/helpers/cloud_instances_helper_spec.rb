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

describe CloudInstancesHelper do

  [:running, :managed, :runaway].each do |instance_type|
    it "should have a cloud_instances_header value for #{instance_type} instance type" do
      helper.cloud_instances_header(instance_type).should_not be_nil
    end

    it "should have a cloud_instances_header_info value for #{instance_type} instance type" do
      helper.cloud_instances_header_info(instance_type).should_not be_nil
    end

    it "should have a cloud_instances_actions? value for #{instance_type} instance type" do
      helper.cloud_instances_actions?(instance_type).should_not be_nil
    end
  end

end
