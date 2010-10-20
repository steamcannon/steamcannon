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

describe MailerTask do
  before(:each) do
    @mailer_task = MailerTask.new
    @payload = { :class_name => 'AMailer', :method => :a_method, :args => [1,2] }
    AMailer = mock('AMailer')
    AMailer.stub!(:deliver_a_method)
  end

  describe "perform" do
    it "should call the deliver method" do
      AMailer.should_receive(:deliver_a_method).with(1,2)
      @mailer_task.perform(@payload)
    end

    it "should send no arguments if none given" do
      @payload.delete(:args)
      AMailer.should_receive(:deliver_a_method).with(no_args())
      @mailer_task.perform(@payload)
    end
  end

end
