require 'spec_helper'

describe CloudProfilesController do
  before(:each) do
    @user = login()
    @current_organization = mock_model(Organization)
    @controller.stub(:current_organization).and_return(@current_organization)
  end
  
  def mock_cloud_profile(stubs={})
    @mock_cloud_profile ||= mock_model(CloudProfile, stubs)
  end

  describe "GET index" do
    it "assigns all cloud_profiles as @cloud_profiles" do
      @current_organization.stub_chain(:cloud_profiles, :find).and_return([mock_cloud_profile])
      get :index
      assigns[:cloud_profiles].should == [mock_cloud_profile]
    end
  end

  describe "GET show" do
    it "assigns the requested cloud_profile as @cloud_profile" do
      @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
      get :show, :id => "37"
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end
  end

  describe "GET new" do
    it "assigns a new cloud_profile as @cloud_profile" do
      @user.stub!(:organization_admin?).and_return(true)
      @current_organization.stub_chain(:cloud_profiles, :build).and_return(mock_cloud_profile)
      get :new
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      get :new
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "GET edit" do
    it "assigns the requested cloud_profile as @cloud_profile" do
      @user.stub!(:organization_admin?).and_return(true)
      @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
      get :edit, :id => "37"
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      get :edit, :id => '1'
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST create" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      post :create
      response.should redirect_to(new_user_session_url)
    end

    describe "with valid params" do
      it "assigns a newly created cloud_profile as @cloud_profile" do
      @current_organization.stub_chain(:cloud_profiles, :build).with({'these' => 'params'}).and_return(mock_cloud_profile(:save => true))
        post :create, :cloud_profile => {:these => 'params'}
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end
      
      it "redirects to the created cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :build).and_return(mock_cloud_profile(:save => true))
        post :create, :cloud_profile => {}
        response.should redirect_to(cloud_profile_url(mock_cloud_profile))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved cloud_profile as @cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :build).with({'these' => 'params'}).and_return(mock_cloud_profile(:save => false))
        post :create, :cloud_profile => {:these => 'params'}
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "re-renders the 'new' template" do
        @current_organization.stub_chain(:cloud_profiles, :build).and_return(mock_cloud_profile(:save => false))
        post :create, :cloud_profile => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
    end

    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      put :update, :id => '1'
      response.should redirect_to(new_user_session_url)
    end

    describe "with valid params" do
      it "updates the requested cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
        mock_cloud_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :cloud_profile => {:these => 'params'}
      end

      it "assigns the requested cloud_profile as @cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => true))
        put :update, :id => "1"
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "redirects to the cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(cloud_profile_url(mock_cloud_profile))
      end
    end

    describe "with invalid params" do
      it "updates the requested cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
        mock_cloud_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :cloud_profile => {:these => 'params'}
      end

      it "assigns the cloud_profile as @cloud_profile" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => false))
        put :update, :id => "1"
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "re-renders the 'edit' template" do
        @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    before(:each) do
      @user.stub!(:organization_admin?).and_return(true)
    end
    
    it "should deny a non-org admin user access" do
      @user.stub!(:organization_admin?).and_return(false)
      delete :update, :id => '1'
      response.should redirect_to(new_user_session_url)
    end

    it "destroys the requested cloud_profile" do
      @current_organization.stub_chain(:cloud_profiles, :find).with("37").and_return(mock_cloud_profile)
      mock_cloud_profile.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the cloud_profiles list" do
      @current_organization.stub_chain(:cloud_profiles, :find).and_return(mock_cloud_profile(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(cloud_profiles_url)
    end
  end

end
