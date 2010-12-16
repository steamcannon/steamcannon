class ApiController < ApplicationController
  helper_method :steamcannon_api_version

  def steamcannon_api_version
    '0.1'
  end

  def index
    respond_to do |format| 
      format.xml # render index.xml.haml
    end
  end
end
