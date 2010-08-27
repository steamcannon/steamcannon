class DashboardController < ApplicationController
  navigation :dashboard
  before_filter :require_user

  def show
    if current_user.superuser?
      render :action => 'dashboard/superuser_show'
    else
      @applications = current_user.apps.all
      @environments = current_user.environments.all
    end
  end
end
