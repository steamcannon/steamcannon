class AccountRequestsController < ResourceController::Base
  before_filter :require_no_user, :only => [:new, :create] 
  before_filter :require_invite_only_mode, :only => [:new, :create]
  before_filter :require_superuser, :except => [:new, :create]

  create.wants.html do
    flash[:notice] = "Your request for an account has been received. If you are accepted, we'll send a signup code to #{object.email}."
    redirect_to new_user_session_url
  end
  
  protected
  def require_invite_only_mode
    if !invite_only_mode?
      flash[:error] = "You can't create an account request."
      redirect_to new_user_session_path
    end
  end
end
