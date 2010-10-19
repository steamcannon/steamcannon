class AccountRequestsController < ResourceController::Base
  before_filter :require_no_user, :only => [:new, :create] 
  before_filter :require_invite_only_mode, :only => [:new, :create]
  before_filter :require_superuser, :except => [:new, :create]

  create.wants.html do
    flash[:notice] = "Your request for an account has been received. If you are accepted, we'll send a signup code to #{object.email}."
    redirect_to new_user_session_url
  end

  def invite
    AccountRequest.find(ids_from_params).each do |account_request|
      account_request.send_invitation(request.host, current_user.email)
    end
    flash[:notice] = "#{ids_from_params.size} invitations queued to be sent."
    redirect_to account_requests_url
  end

  def ignore
    AccountRequest.find(ids_from_params).each do |account_request|
      account_request.ignore!
    end
    flash[:notice] = "#{ids_from_params.size} invitations ignored."
    redirect_to account_requests_url
  end
  
  protected
  def require_invite_only_mode
    if !invite_only_mode?
      flash[:error] = "You can't create an account request."
      redirect_to new_user_session_path
    end
  end

  def ids_from_params
    @ids_from_params ||= params[:account_request_ids] ? params[:account_request_ids] : [params[:account_request_id].to_i]
  end
end
