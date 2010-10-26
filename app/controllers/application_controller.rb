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


# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement

  before_filter :require_complete_profile

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Export to views
  helper_method :current_user_session, :current_user, :open_signup_mode?, :invite_only_mode?

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  protected

  def ssl_required?
    APP_CONFIG[:require_ssl_for_web]
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def open_signup_mode?
    APP_CONFIG[:signup_mode].to_s == 'open_signup'
  end

  def invite_only_mode?
    !open_signup_mode?
  end

  def require_complete_profile
    return false unless current_user
    store_location and redirect_to edit_account_path unless current_user.profile_complete?
  end

  def require_user
    unless current_user
      store_location
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      redirect_to root_url
      return false
    end
  end

  def require_superuser
    if !current_user || !current_user.superuser?
      store_location
      redirect_to new_user_session_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_stored_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_back_or_default(default, opts={})
    if request.env["HTTP_REFERER"]
      redirect_to(:back, opts)
    else
      redirect_to(default, opts)
    end
  end

  def generate_json_response(type, hash = {})
    unless [ :ok, :redirect, :error ].include?(type)
      raise "Invalid json response type: #{type}"
    end
    response = {
      :status => type,
      :html => nil,
      :message => nil,
      :to => nil }.merge(hash)

    {:json => response}
  end
end
