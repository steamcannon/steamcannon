class HardwareProfilesController < ApplicationController

  before_filter :require_user

  # GET /hardware_profiles
  def index
    @cloud = current_user.cloud
    respond_to do |format|
      format.xml # render index.xml.haml
    end
  end

  # GET /hardware_profile/t1-micro
  def show
    @profile = params[:id]
    @cloud = current_user.cloud
    respond_to do |format|
      format.xml # render show.xml.haml
    end
  end

end
