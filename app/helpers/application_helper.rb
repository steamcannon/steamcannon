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


# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def dom_class_for_body
    %(#{params[:controller]}_controller #{params[:action]}_action)
  end

  def content_for_superuser(text = nil, &block)
    raise ArgumentError.new("Don't supply both text and a block") if text and block_given?
    concat(text || capture(&block)) if current_user.superuser?
  end

  def style_display_none
    { :style => 'display: none;' }
  end
end
