class ImagesController < ApplicationController
  def index
    @environment = current_user.environments.find(params[:environment_id])
    @images = @environment.images
  end

  def show
    @environment = current_user.environments.find(params[:environment_id])
    # It's all complicated like this to scope the DB query to the user instead of just using CloudImage.find_by_cloud_id
    @cloud_image = @environment.images.collect{|i|i.cloud_images}.flatten.first{|ci|ci.cloud_id == params[:id]} 
    @image = @cloud_image.image
  end
end
