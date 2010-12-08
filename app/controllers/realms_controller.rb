class RealmsController < ApplicationController
  before_filter :require_user

  def index
    @realms = current_user.cloud.realms
  end

  def show
    @realm = current_user.cloud.realms.select { |realm| realm.name == params[:id] }.first
  end

end
