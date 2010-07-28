require 'spec_helper'

describe DeploymentsController do
  before(:each) do
    login
    @current_user.stub!(:deployments).and_return(Deployment)
  end

  def mock_deployment(stubs={})
    stubs.merge!(:app => mock_app)
    @mock_deployment ||= mock_model(Deployment, stubs)
  end

  def mock_app(stubs={})
    @mock_app ||= mock_model(App, stubs)
  end

  describe "GET index" do
    it "assigns all deployments as @deployments" do
      Deployment.stub(:find).with(:all).and_return([mock_deployment])
      get :index
      assigns[:deployments].should == [mock_deployment]
    end
  end

  describe "GET show" do
    it "assigns the requested deployment as @deployment" do
      Deployment.stub(:find).with("37").and_return(mock_deployment)
      get :show, :id => "37"
      assigns[:deployment].should equal(mock_deployment)
    end
  end

  describe "GET new" do
    before(:each) do
      Deployment.stub(:new).and_return(mock_deployment)
      mock_deployment.stub!(:datasource).and_return(nil)
      mock_deployment.stub!(:datasource=)
    end

    it "assigns a new deployment as @deployment" do
      get :new
      assigns[:deployment].should equal(mock_deployment)
    end

    it "defaults to local datasource" do
      mock_deployment.should_receive(:datasource=).with("local")
      get :new
    end
  end

  describe "POST create" do
    before(:each) do
      mock_deployment.stub!(:environment).and_return(Environment.new)
    end

    describe "with valid params" do
      before(:each) do
        mock_deployment.stub!(:save).and_return(true)
      end

      it "assigns a newly created deployment as @deployment" do
        Deployment.stub(:new).with({'these' => 'params'}).and_return(mock_deployment)
        post :create, :deployment => {:these => 'params'}
        assigns[:deployment].should equal(mock_deployment)
      end

      it "redirects to the app show page" do
        Deployment.stub(:new).and_return(mock_deployment)
        post :create, :deployment => {}
        response.should redirect_to(app_url(mock_deployment.app))
      end
    end

    describe "with invalid params" do
      before(:each) do
        mock_deployment.stub!(:save).and_return(false)
      end

      it "assigns a newly created but unsaved deployment as @deployment" do
        Deployment.stub(:new).with({'these' => 'params'}).and_return(mock_deployment)
        post :create, :deployment => {:these => 'params'}
        assigns[:deployment].should equal(mock_deployment)
      end

      it "re-renders the 'new' template" do
        Deployment.stub(:new).and_return(mock_deployment)
        post :create, :deployment => {}
        response.should render_template('new')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested deployment" do
      Deployment.should_receive(:find).with("37").and_return(mock_deployment)
      mock_deployment.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the app show page" do
      Deployment.stub(:find).and_return(mock_deployment(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(app_url(mock_deployment.app))
    end
  end

end
