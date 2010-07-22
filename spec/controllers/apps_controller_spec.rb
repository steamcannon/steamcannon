require 'spec_helper'

describe AppsController do
  before(:each) do
    login

    @cluster = mock_model(Cluster)
    Cluster.stub!(:new).and_return(@cluster)

    App.stub!(:all).and_return([])
  end

  describe "GET /apps" do
    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET /apps/:id" do

    describe "with valid params" do
      before(:each) do
        @app = mock_model(App)
        App.stub!(:find).with("1").and_return(@app)
      end

      it "should be successful" do
        get :show, :id => "1"
        response.should be_success
      end

      it "should find app and return object" do
        App.should_receive(:find).with("1").and_return(@app)
        get :show, :id => "1"
      end
    end

    describe "with invalid params" do
      before(:each) do
        App.stub!(:find).with("1").and_return(nil)
      end

      it "should redirect to root path" do
        get :show, :id => "1"
        response.should redirect_to(root_url)
      end
    end
  end

  describe "GET /apps/new" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "POST /apps" do
    before(:each) do
      @app = mock_model(App)
      App.stub!(:new).and_return(@app)

      @cluster.stub!(:running?).and_return(true)
    end

    describe "with valid params" do
      before(:each) do
        @app.stub!(:save).and_return(true)
      end

      it "should create new app" do
        App.should_receive(:new).and_return(@app)
        post :create
      end
    end

    describe "with invalid params" do
      before(:each) do
        @app.stub!(:save).and_return(false);
      end

      it "should redirect to show page" do
        post :create
        response.should redirect_to(app_url(@app))
      end
    end
  end

end
