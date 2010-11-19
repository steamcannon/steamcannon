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

describe Event do
  before(:each) do
    @event = Factory.build(:event)
  end
  
  it { should belong_to :event_subject }

  describe "error" do
    it "should return error as hash of :type, :message, :backtrace" do
      error = mock(Exception, :message => 'the message', :backtrace => %w{ line_1 line_2 })
      @event.error = error
      @event.error.should == { :type => error.class.name, :message => error.message, :backtrace => error.backtrace.join("\n") }
    end

    it "should handle nil properly" do
      @event.error = nil
      @event.error.should be_nil
    end
    
    it "should return :type and :backtrace as empty strings if only a message is provided" do
      @event.error = 'the error'
      @event.error.should == { :message => 'the error', :type => '', :backtrace => '' }
    end
  end
end
