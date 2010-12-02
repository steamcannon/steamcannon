class ImagesController < ApplicationController
  def index
    @environment = current_user.environments.find(params[:environment_id])
    @images = @environment.images
  end
  def show
    @environment = current_user.environments.find(params[:environment_id])
  end
end
