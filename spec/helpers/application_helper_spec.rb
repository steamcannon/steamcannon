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

describe ApplicationHelper do
  include ApplicationHelper
  
  describe "content_for_superuser" do
    context "for a superuser" do
      before(:each) do
        @current_user = Factory.build(:superuser)
        stub!(:current_user).and_return(@current_user)
      end
      
      it "should concat the given text" do
        should_receive(:concat).with('some text')
        content_for_superuser("some text")
      end

      it "should concat the block results" do
        should_receive(:concat).with('SOME TEXT')
        content_for_superuser do
          'some text'.upcase
        end
      end
    end

    context "for a non superuser" do
      before(:each) do
        @current_user = Factory.build(:user)
        stub!(:current_user).and_return(@current_user)
      end
      
      it "should not concat the given text" do
        should_not_receive(:concat)
        content_for_superuser("some text")
      end

      it "should not concat the block results" do
        should_not_receive(:concat)
        content_for_superuser do
          'some text'.upcase
        end
      end
    end

    it "should raise an error if block and text both provided" do
      lambda {
        content_for_superuser('text') { }
      }.should raise_error(ArgumentError)
    end
  end

end

