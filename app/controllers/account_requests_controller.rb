#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

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
      from = APP_CONFIG[:default_reply_to_address] || current_user.email
      account_request.send_invitation(request.host, from)
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
