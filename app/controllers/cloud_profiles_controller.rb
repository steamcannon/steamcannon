class CloudProfilesController < ApplicationController
  # GET /cloud_profiles
  # GET /cloud_profiles.xml
  def index
    @cloud_profiles = CloudProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cloud_profiles }
    end
  end

  # GET /cloud_profiles/1
  # GET /cloud_profiles/1.xml
  def show
    @cloud_profile = CloudProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cloud_profile }
    end
  end

  # GET /cloud_profiles/new
  # GET /cloud_profiles/new.xml
  def new
    @cloud_profile = CloudProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cloud_profile }
    end
  end

  # GET /cloud_profiles/1/edit
  def edit
    @cloud_profile = CloudProfile.find(params[:id])
  end

  # POST /cloud_profiles
  # POST /cloud_profiles.xml
  def create
    @cloud_profile = CloudProfile.new(params[:cloud_profile])

    respond_to do |format|
      if @cloud_profile.save
        format.html { redirect_to(@cloud_profile, :notice => 'CloudProfile was successfully created.') }
        format.xml  { render :xml => @cloud_profile, :status => :created, :location => @cloud_profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cloud_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cloud_profiles/1
  # PUT /cloud_profiles/1.xml
  def update
    @cloud_profile = CloudProfile.find(params[:id])

    respond_to do |format|
      if @cloud_profile.update_attributes(params[:cloud_profile])
        format.html { redirect_to(@cloud_profile, :notice => 'CloudProfile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cloud_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cloud_profiles/1
  # DELETE /cloud_profiles/1.xml
  def destroy
    @cloud_profile = CloudProfile.find(params[:id])
    @cloud_profile.destroy

    respond_to do |format|
      format.html { redirect_to(cloud_profiles_url) }
      format.xml  { head :ok }
    end
  end
end
