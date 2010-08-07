class DashboardController < ApplicationController
  navigation :dashboard
  before_filter :require_user

  def show
    @applications = current_user.apps.all
    @environments = current_user.environments.running.all
  end
end
