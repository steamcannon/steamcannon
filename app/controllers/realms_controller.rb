class RealmsController < ApplicationController
  before_filter :require_user
  before_filter :load_environment

  def index
    @realms = current_user.cloud.realms
  end

  def show
    @realm = current_user.cloud.realms.select { |realm| realm.name == params[:id] }.first
  end

  protected
  def load_environment
    @environment = current_user.environments.find(params[:environment_id])
  end

end
