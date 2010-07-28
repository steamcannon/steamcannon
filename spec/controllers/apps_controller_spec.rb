require 'spec_helper'

describe AppsController do
  before(:each) do
    login
    @current_user.stub!(:apps).and_return(App)
    App.stub!(:all).and_return([])
  end

  def mock_app(stubs={})
    # stubs.merge!({:app_versions => AppVersion})
    @mock_app ||= mock_model(App, stubs)
  end

  describe "GET /apps" do
    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET /apps/1" do
    before(:each) do
      App.stub!(:find).with("37").and_return(mock_app)
    end

    it "should be successful" do
      get :show, :id => "37"
      response.should be_success
    end

    it "assigns the request app as @app" do
      App.should_receive(:find).with("37").and_return(mock_app)
      get :show, :id => "37"
      assigns[:app].should equal(mock_app)
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
    end

    describe "with valid params" do
      before(:each) do
        @app.stub!(:save).and_return(true)
      end

      it "should create new app" do
        App.should_receive(:new).and_return(@app)
        post :create
      end

      it "should have a flash notice" do
        post :create
        flash[:notice].should_not be_blank
      end

      it "should redirect to the app show page" do
        post :create
        response.should redirect_to(app_path(@app))
      end
    end

    describe "with invalid params" do
      before(:each) do
        @app.stub!(:save).and_return(false);
      end

      it "should display new form" do
        post :create
        response.should render_template(:new)
      end
    end
  end

  describe "GET /apps/:id/edit" do
    before(:each) do
      @app = mock_model(App)
      App.stub!(:find).and_return(@app)
    end

    it "should be successful" do
      get :edit, :id => "1"
      response.should be_success
    end

    it "should find and return app object" do
      App.should_receive(:find).with("1").and_return(@app)
      get :edit, :id => "1"
    end
  end

  describe "PUT /apps/:id" do
    before(:each) do
      @app = mock_model(App)
      App.stub!(:find).with("1").and_return(@app)
    end

    describe "with valid params" do
      before(:each) do
        @app.stub!(:update_attributes).and_return(true)
      end

      it "should find and return app object" do
        App.should_receive(:find).with("1").and_return(@app)
        put :update, :id => "1"
      end

      it "should update the app object's attributes" do
        @app.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should have a flash notice" do
        put :update, :id => "1"
        flash[:notice].should_not be_blank
      end

      it "should redirect to the app show page" do
        put :update, :id => "1"
        response.should redirect_to(app_path(@app))
      end
    end

    describe "with invalid params" do
      before(:each) do
        @app.stub!(:update_attributes).and_return(false)
      end

      it "should find and return app object" do
        App.should_receive(:find).with("1").and_return(@app)
        put :update, :id => "1"
      end

      it "should update the app object's attributes" do
        @app.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should render the edit form" do
        put :update, :id => "1"
        response.should render_template(:edit)
      end
    end
  end

  describe "DELETE /apps/:id" do
    before(:each) do
      @app = mock_model(App)
      App.stub!(:find).and_return(@app)
      @app.stub!(:destroy)
      @app.stub!(:name).and_return("my app")
    end

    it "should redirect to apps index page" do
      delete :destroy, :id => "1"
      response.should redirect_to(apps_path)
    end

    it "should have a flash notice" do
      delete :destroy, :id => "1"
      flash[:notice].should_not be_blank
    end
  end

end
