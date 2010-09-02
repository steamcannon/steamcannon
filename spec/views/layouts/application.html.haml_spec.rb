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

require 'spec_helper'

describe "/layouts/application" do

  # Tests commented out for now until we stabilize navigation / integration

  # describe "when logged in" do
  #   before(:each) { login }

  #   it "should display the navigation tabs" do
  #     render 'layouts/application'
  #     response.should have_tag('div[class=?]', 'navigation_menu')
  #   end
  # end

  # describe "when logged out" do
  #   before(:each) { logout }

  #   it "should not display the navigation tabs" do
  #     render 'layouts/application'
  #     response.should_not have_tag('div[class=?]', 'navigation_menu')
  #   end
  # end
end
