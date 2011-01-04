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

describe Cloud::Storage::FileStorage do
  before(:each) do
    @storage = Cloud::Storage::FileStorage.new(nil)
    @artifact_version = Factory.build(:artifact_version)
    @path = 'path/to/file.war'
    @storage.stub!(:path).and_return(@path)
  end

  describe "write" do
    before(:each) do
      @old_path = 'old_path/to/file.war'
      @file = mock(File)
      @file.stub!(:path).and_return(@old_path)
      @file.stub!(:close)
      @artifact_version.stub_chain(:archive, :to_file).and_return(@file)
      FileUtils.stub!(:mkdir_p)
      FileUtils.stub!(:cp)
      FileUtils.stub!(:rm)
      FileUtils.stub!(:chmod)
    end

    it "should close the file" do
      @file.should_receive(:close)
      @storage.write(@artifact_version)
    end

    it "should create the directory tree" do
      FileUtils.should_receive(:mkdir_p).with('path/to')
      @storage.write(@artifact_version)
    end

    it "should copy the file to the new path" do
      FileUtils.should_receive(:cp).with(@old_path, @path)
      @storage.write(@artifact_version)
    end

    it "should remove the old file" do
      FileUtils.should_receive(:rm).with(@old_path)
      @storage.write(@artifact_version)
    end

    it "should set permissions on the new file" do
      FileUtils.should_receive(:chmod).with(0644, @path)
      @storage.write(@artifact_version)
    end
  end

  describe "delete" do
    before(:each) do
      @storage.stub!(:path).and_return(@path)
      FileUtils.stub!(:rm)
      @storage.stub!(:exists?).and_return(true)
    end

    it "should remove the file" do
      FileUtils.should_receive(:rm).with(@path)
      @storage.delete(@artifact_version)
    end

    it "should ignore file not found errors" do
      lambda {
        FileUtils.should_receive(:rm).and_raise(Errno::ENOENT)
        @storage.delete(@artifact_version)
      }.should_not raise_error
    end

    it "should not ignore other types of errors" do
      lambda {
        FileUtils.should_receive(:rm).and_raise("different error")
        @storage.delete(@artifact_version)
      }.should raise_error
    end
  end

  describe "public_url" do
    it "should be nil" do
      @storage.public_url.should be(nil)
    end
  end
end
