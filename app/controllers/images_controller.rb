#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

class ImagesController < ApplicationController
  before_filter :require_user

  def index
    begin
      @environment = current_user.environments.find(params[:environment_id])
      @images = @environment.images
    rescue ActiveRecord::RecordNotFound
      render :text => '', :status => 404
    end
  end

  def show
    begin
      @environment = current_user.environments.find(params[:environment_id])
      @image = @environment.images.find(params[:id]) unless @environment.blank?
      # It's all complicated like this to scope the DB query to the user instead of just using CloudImage.find_by_cloud_id
      @cloud_image = @image.cloud_images.flatten.first{|ci|ci.cloud_id == params[:id]} unless @image.blank?
    rescue ActiveRecord::RecordNotFound
      render :text => '', :status => 404
    end
  end
end
