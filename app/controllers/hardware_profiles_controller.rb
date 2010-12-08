class HardwareProfilesController < ApplicationController

  before_filter :require_user

  # GET /environments/1/hardware_profiles
  def index 
    @cloud = current_user.cloud
  end

  # GET /environments/1/hardware_profile/t1-micro
  def show
    @profile = params[:id]
    @cloud = current_user.cloud
  end

end
