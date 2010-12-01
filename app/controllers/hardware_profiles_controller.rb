class HardwareProfilesController < ApplicationController

  before_filter :require_user
  helper_method [:pathify, :deltacloudify]

  # GET /environments/1/hardware_profiles
  def index 
    @cloud = current_user.cloud
    @environment = current_user.environments.find(params[:environment_id])
  end

  # GET /environments/1/hardware_profile/t1-micro
  def show
    @profile = params[:id]
    @cloud = current_user.cloud
    @environment = current_user.environments.find(params[:environment_id])
  end

  # These are annoying, but necessary since rails routes barf if an ID has a '.' in it
  def pathify(profile_id)
    profile_id.sub('.', '-')
  end

  def deltacloudify(profile_id)
    profile_id.sub('-', '.')
  end

end
