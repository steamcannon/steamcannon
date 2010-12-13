require 'spec_helper'

describe CloudProfilesController do

  def mock_cloud_profile(stubs={})
    @mock_cloud_profile ||= mock_model(CloudProfile, stubs)
  end

  describe "GET index" do
    it "assigns all cloud_profiles as @cloud_profiles" do
      CloudProfile.stub(:find).with(:all).and_return([mock_cloud_profile])
      get :index
      assigns[:cloud_profiles].should == [mock_cloud_profile]
    end
  end

  describe "GET show" do
    it "assigns the requested cloud_profile as @cloud_profile" do
      CloudProfile.stub(:find).with("37").and_return(mock_cloud_profile)
      get :show, :id => "37"
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end
  end

  describe "GET new" do
    it "assigns a new cloud_profile as @cloud_profile" do
      CloudProfile.stub(:new).and_return(mock_cloud_profile)
      get :new
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end
  end

  describe "GET edit" do
    it "assigns the requested cloud_profile as @cloud_profile" do
      CloudProfile.stub(:find).with("37").and_return(mock_cloud_profile)
      get :edit, :id => "37"
      assigns[:cloud_profile].should equal(mock_cloud_profile)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created cloud_profile as @cloud_profile" do
        CloudProfile.stub(:new).with({'these' => 'params'}).and_return(mock_cloud_profile(:save => true))
        post :create, :cloud_profile => {:these => 'params'}
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "redirects to the created cloud_profile" do
        CloudProfile.stub(:new).and_return(mock_cloud_profile(:save => true))
        post :create, :cloud_profile => {}
        response.should redirect_to(cloud_profile_url(mock_cloud_profile))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved cloud_profile as @cloud_profile" do
        CloudProfile.stub(:new).with({'these' => 'params'}).and_return(mock_cloud_profile(:save => false))
        post :create, :cloud_profile => {:these => 'params'}
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "re-renders the 'new' template" do
        CloudProfile.stub(:new).and_return(mock_cloud_profile(:save => false))
        post :create, :cloud_profile => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested cloud_profile" do
        CloudProfile.should_receive(:find).with("37").and_return(mock_cloud_profile)
        mock_cloud_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :cloud_profile => {:these => 'params'}
      end

      it "assigns the requested cloud_profile as @cloud_profile" do
        CloudProfile.stub(:find).and_return(mock_cloud_profile(:update_attributes => true))
        put :update, :id => "1"
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "redirects to the cloud_profile" do
        CloudProfile.stub(:find).and_return(mock_cloud_profile(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(cloud_profile_url(mock_cloud_profile))
      end
    end

    describe "with invalid params" do
      it "updates the requested cloud_profile" do
        CloudProfile.should_receive(:find).with("37").and_return(mock_cloud_profile)
        mock_cloud_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :cloud_profile => {:these => 'params'}
      end

      it "assigns the cloud_profile as @cloud_profile" do
        CloudProfile.stub(:find).and_return(mock_cloud_profile(:update_attributes => false))
        put :update, :id => "1"
        assigns[:cloud_profile].should equal(mock_cloud_profile)
      end

      it "re-renders the 'edit' template" do
        CloudProfile.stub(:find).and_return(mock_cloud_profile(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested cloud_profile" do
      CloudProfile.should_receive(:find).with("37").and_return(mock_cloud_profile)
      mock_cloud_profile.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the cloud_profiles list" do
      CloudProfile.stub(:find).and_return(mock_cloud_profile(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(cloud_profiles_url)
    end
  end

end
