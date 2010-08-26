class UsersController < ResourceController::Base
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :require_superuser, :only => [:assume_user]

  create do 
    flash { "Account registered" }
    wants.html { redirect_stored_or_default root_url }
  end
  
  update do
    flash { "Account updated" }
    wants.html do
      # lets us share this action between self managed accounts and
      # admin'ed users
      if object == current_user
        redirect_to account_url
      else
        redirect_to object_url
      end

    end
  end

  def assume_user
    UserSession.create(object)
    flash[:notice] = "You have assumed the account of '#{object.email}'. You will need to logout and back in to return to your account."
    redirect_to root_path
  end
  
  protected
  def object
    super || current_user
  end

end
