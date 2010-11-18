require 'spec_helper'

describe EventsController do

  before(:each) do
    @current_user = Factory(:user)
    @current_user.stub!(:profile_complete?).and_return(true)
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
