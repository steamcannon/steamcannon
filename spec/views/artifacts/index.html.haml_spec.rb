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

describe "/artifacts/index.html.haml" do
  include ArtifactsHelper

  before(:each) do
    assigns[:artifacts] = [
                           stub_model(Artifact,
                                      :name => "value for name",
                                      :description => "value for description"
                                      ),
                           stub_model(Artifact,
                                      :name => "value for name",
                                      :description => "value for description"
                                      )
                          ]
  end

  it "renders a list of artifacts" do
    render
    response.should have_tag("div.artifact_name", "value for name".to_s, 2)
  end

  it "renders a link to upload a new artifact" do
    render
    response.should have_tag("a[href=?]", new_artifact_path)
  end
end
