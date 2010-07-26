class DashboardController < ApplicationController
  navigation :dashboard
  before_filter :require_user

  def show
  end
end
