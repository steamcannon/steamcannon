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

class PasswordResetsController < ApplicationController
  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
  before_filter :require_no_user
  
  def create  
    @user = User.find_by_email(params[:email])  
    if @user  
      @user.send_password_reset_instructions!  
      flash[:notice] = "Thanks! Check your email for instructions on how to reset your password. "
      redirect_to root_path
    else  
      flash[:notice] = "Sorry! I can't find a user with that email address."
      render :action => :new  
    end  
  end  
  
  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "Password successfully updated"  
      redirect_to dashboard_path
    else  
      render :action => :edit  
    end  
  end  
  
  private
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate that account. "
      redirect_to root_path
    end
  end
  
end
