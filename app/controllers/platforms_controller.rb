class PlatformsController < ResourceController::Base
  before_filter :require_superuser
end
