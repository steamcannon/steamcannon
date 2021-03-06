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

class AccountRequestMailer < ActionMailer::Base
  

  def invitation(host, sender, to, token)
    subject    "[SteamCannon] your request for an account has been accepted"
    recipients to
    from       sender
    
    body       :url => new_user_from_token_url(:host => host, :token => token)
  end

  def request_notification(host, request, to)
    subject    "[SteamCannon] #{request.email} is requesting an account"
    recipients to
    from       to
    
    body       :url => account_requests_url(:host => host), :request => request
  end

end
