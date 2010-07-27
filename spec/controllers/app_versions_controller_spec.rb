require 'spec_helper'

describe AppVersionsController do
  before(:each) do
    login
    @current_user.stub!(:apps).and_return(App)
    App.stub!(:find).with("29").and_return(mock_app)
  end

  def mock_app_version(stubs={})
    @mock_app_version ||= mock_model(AppVersion, stubs)
  end

  def mock_app(stubs={})
    stubs.merge!({:app_versions => AppVersion})
    @mock_app ||= mock_model(App, stubs)
  end

  describe "GET new" do
    it "assigns a new app_version as @app_version" do
      AppVersion.stub(:new).and_return(mock_app_version)
      get :new, :app_id => "29"
      assigns[:app_version].should equal(mock_app_version)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created app_version as @app_version" do
        AppVersion.stub(:new).with({'these' => 'params'}).and_return(mock_app_version(:save => true))
        post :create, :app_version => {:these => 'params'}, :app_id => "29"
        assigns[:app_version].should equal(mock_app_version)
      end

      it "redirects to the app" do
        AppVersion.stub(:new).and_return(mock_app_version(:save => true))
        post :create, :app_version => {}, :app_id => "29"
        response.should redirect_to(app_url(mock_app))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved app_version as @app_version" do
        AppVersion.stub(:new).with({'these' => 'params'}).and_return(mock_app_version(:save => false))
        post :create, :app_version => {:these => 'params'}, :app_id => "29"
        assigns[:app_version].should equal(mock_app_version)
      end

      it "re-renders the 'new' template" do
        AppVersion.stub(:new).and_return(mock_app_version(:save => false))
        post :create, :app_version => {}, :app_id => "29"
        response.should render_template('new')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested app_version" do
      AppVersion.should_receive(:find).with("37").and_return(mock_app_version)
      mock_app_version.should_receive(:destroy)
      delete :destroy, :id => "37", :app_id => "29"
    end

    it "redirects to the app" do
      AppVersion.stub(:find).and_return(mock_app_version(:destroy => true))
      delete :destroy, :id => "1", :app_id => "29"
      response.should redirect_to(app_url(mock_app))
    end
  end

end
