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

describe ModelTask do
  before(:each) do
    @model_task = ModelTask.new
    @payload = { :class_name => 'AModel', :id => 123, :method => :a_method }
    @model = mock('model')
    @model.stub!(:a_method)
    AModel = mock('AModel')
    AModel.stub!(:find).and_return(@model)
  end

  describe "perform" do
    it "should lookup the model by id" do
      AModel.should_receive(:find).with(123).and_return(@model)
      @model_task.perform(@payload)
    end

    it "should call the method" do
      @model.should_receive(:a_method)
      @model_task.perform(@payload)
    end

    it "should pass along any args" do
      @payload[:args] = [1,2]
      @model.should_receive(:a_method).with(1,2)
      @model_task.perform(@payload)
    end
  end

end
