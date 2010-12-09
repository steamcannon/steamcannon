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


class UsersController < ResourceController::Base
  navigation :users

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_open_signup_mode_or_token, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :validate_cloud_credentials, :cloud_defaults_block]
  before_filter :require_superuser, :only => [:assume_user]
  before_filter :require_superuser_to_edit_other_user, :only => [:edit, :update]
  before_filter :require_organization_admin, :only => [:promote, :demote]
  skip_before_filter :require_complete_profile, :except => [:show]

  new_action.before do
    object.email = @account_request.email if @account_request
    object.organization = @account_request.organization if @account_request
  end

  edit.before do
    flash[:error] = "Please complete your profile before continuing." unless current_user.profile_complete?
  end

  update.before do
    if params && params[:user] && params[:user][:organization_attributes]
      if current_user.organization_admin?
        if params[:user][:organization_attributes][:cloud_password].blank?
          params[:user][:organization_attributes].delete(:cloud_password)
        else
          object.organization.cloud_password_dirty = true
        end
      else
        params[:user].delete(:organization_attributes)
      end
    end
  end

  create do
    flash { "Account registered" }
    before { object.organization = @account_request.organization if @account_request }
    after { @account_request.accept! if @account_request }
    wants.html { redirect_stored_or_default root_url }
  end

  update do
    flash { "Account updated" }
    wants.html do
      # lets us share this action between self managed accounts and
      # admin'ed users
      if object == current_user
        redirect_stored_or_default account_url
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

  def promote
    object.organization_admin = true
    object.save!
    flash[:notice] = "User #{object.email} promoted to organization admin."
    redirect_to users_path
  end

  def demote
    object.organization_admin = false
    object.save!
    flash[:notice] = "User #{object.email} demoted to regular user."
    redirect_to users_path
  end

  def validate_cloud_credentials
    update_cloud_credentials_from_params
    valid = object.cloud.attempt(:valid_credentials?, false)
    render(generate_json_response(valid ? :ok : :error))
  end

  def cloud_defaults_block
    update_cloud_credentials_from_params
    render(:partial => 'users/cloud_defaults', :locals => { :user => object })
  end

  protected
  def object
    super || current_user
  end

  def collection
    end_of_association_chain.visible_to_user(current_user).sorted_by(sort_column(User, :email), sort_direction)
  end

  def require_superuser_to_edit_other_user
    if !current_user.superuser? and current_user != object
      flash[:error] = "You don't have the proper rights to edit that user."
      redirect_to new_user_session_path
    end
  end

  def require_open_signup_mode_or_token
    if params[:token] and
        @account_request = AccountRequest.invited.find_by_token(params[:token])
      flash.now[:notice] = "Please create an account to continue."
    elsif !open_signup_mode?
      flash[:error] = "You can't create a new user."
      redirect_to new_user_session_path
    end
  end

  def update_cloud_credentials_from_params
    org = object.organization
    org.cloud_username = params[:cloud_username] if params[:cloud_username]
    org.cloud_password = params[:cloud_password] unless params[:cloud_password].blank?
  end
end
