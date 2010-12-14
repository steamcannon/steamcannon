class RealmsController < ApplicationController
  before_filter :require_user

  def index
    @realms = current_user.cloud.realms
    respond_to do |format|
      format.xml # render index.xml.haml
    end
  end

  def show
    @realm = current_user.cloud.realms.select { |realm| realm.name == params[:id] }.first
    respond_to do |format|
      format.xml # render show.xml.haml
    end
  end

end
