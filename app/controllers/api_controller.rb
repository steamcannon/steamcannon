class ApiController < ApplicationController
  helper_method :steamcannon_api_version

  def steamcannon_api_version
    '0.1'
  end
end
