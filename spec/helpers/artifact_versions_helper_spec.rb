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

describe ArtifactVersionsHelper do

  describe "artifact_version_download_link" do
    before(:each) do
      @artifact_version = Factory.build(:artifact_version,
                                        :archive_file_name => 'file_name')
      @archive = mock('archive')
      @artifact_version.stub!(:archive).and_return(@archive)
    end

    it "should link to public_url if non-nil" do
      @archive.should_receive(:public_url).twice.and_return('public_url')
      helper.should_receive(:link_to).with('file_name', 'public_url')
      helper.artifact_version_download_link(@artifact_version)
    end

    it "should return file name if public_url is nil" do
      @archive.should_receive(:public_url).and_return(nil)
      helper.artifact_version_download_link(@artifact_version).should == 'file_name'
    end
  end

end
