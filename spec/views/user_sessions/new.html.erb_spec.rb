require 'spec_helper'

describe "/user_sessions/new" do
  before(:each) do
    @user_session = mock_model(UserSession)
    assigns[:user_session] = @user_session
  end

  it "should display the login form" do
    @user_session.should_receive(:email).and_return(nil)
    @user_session.should_receive(:password).and_return(nil)
    render 'user_sessions/new'
    response.should have_tag('form[action=?]', user_session_path)
  end

  it "should display email if given" do
    @user_session.should_receive(:email).and_return("my_email@test.com")
    @user_session.should_receive(:password).and_return(nil)
    render 'user_sessions/new'
    response.should have_tag('input[value=?]', "my_email@test.com")
  end
end
