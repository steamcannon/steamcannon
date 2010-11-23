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

describe StorageVolumeWatcher do
  before(:each) do
    @instance_watcher = StorageVolumeWatcher.new
  end

  describe 'run' do
    before(:each) do
      @instance_watcher.stub!(:destroy_volumes_pending_delete)
      @instance_watcher.stub!(:check_for_volume_existence)
    end

    it "should try to destroy volumes marked for destruction" do
      @instance_watcher.should_receive(:destroy_volumes_pending_delete)
      @instance_watcher.run
    end

    it "should check for volume existence" do
      @instance_watcher.should_receive(:check_for_volume_existence)
      @instance_watcher.run
    end
  end

  it "should attempt to destroy any pending_delete storage_volumes" do
    storage_volume = mock_model(StorageVolume)
    storage_volume.should_receive(:real_destroy)
    StorageVolume.stub!(:pending_delete).and_return([storage_volume])
    @instance_watcher.destroy_volumes_pending_delete
  end

  describe "check_for_volume_existence" do
    before(:each) do
      @storage_volume = mock_model(StorageVolume)
      StorageVolume.should_receive(:should_exist).and_return([@storage_volume])
    end

    it "should move non-existent storage volumes to not_found" do
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(false)
      @storage_volume.should_receive(:not_found!)
      @instance_watcher.check_for_volume_existence
    end

    it "should not move existing volumes" do
      @storage_volume.should_receive(:cloud_volume_exists?).and_return(true)
      @storage_volume.should_not_receive(:not_found!)
      @instance_watcher.check_for_volume_existence
    end
  end

end
