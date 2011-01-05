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

describe EventsController do

  before(:each) do
    @current_user = Factory(:user)
    login_with_user(@current_user)
    @event_subject = Factory(:event_subject, :owner => @current_user)
    @event = Factory(:event, :event_subject => @event_subject)
  end


  describe 'index' do
    context 'with a valid subject' do 
      it "should set the @event_subject" do
        get :index, :subject_id => @event_subject.id
        assigns[:event_subject].should == @event_subject
      end

      it "should set a list of events" do
        get :index, :subject_id => @event_subject.id
        assigns[:events].should == [@event]
      end
      
      it "should render the index" do
        get :index, :subject_id => @event_subject.id
        response.should render_template('events/index')
      end
    end

    context "with an invalid subject" do
      it "should redir to the dashboard if the subject is not accessible to the current_user" do
        get :index, :subject_id => Factory(:event_subject).id
        response.should redirect_to dashboard_path
      end
      
      it 'should set the flash' do
        get :index, :subject_id => Factory(:event_subject).id
        flash[:notice].should == 'Those requested events do not exist, or are not accessible from your account.'
      end
    end
    
  end

end
