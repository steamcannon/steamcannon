class DashboardController < ApplicationController
  navigation :dashboard
  before_filter :require_user

  def show
    @deployments = current_user.deployments.all
    @environments = current_user.environments.running.all
  end
end
