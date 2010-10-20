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
    @storage = Cloud::Storage::FileStorage.new(nil, nil, nil)
    @path = 'path/to/file.war'
  end

  describe "exists?" do
    it "should call File.exist?" do
      File.should_receive(:exist?).with(@path).and_return(true)
      @storage.exists?(@path).should be(true)
    end
  end

  describe "to_file" do
    before(:each) do
      @file = mock(File)
      File.stub!(:new).and_return(@file)
      @storage.stub!(:exists?).and_return(true)
    end

    it "should verify file exists" do
      @storage.should_receive(:exists?).with(@path)
      @storage.to_file(@path)
    end

    it "should return new File object opened for binary reading" do
      File.should_receive(:new).with(@path, 'rb').and_return(@file)
      @storage.to_file(@path).should be(@file)
    end
  end

  describe "write" do
    before(:each) do
      @old_path = 'old_path/to/file.war'
      @file = mock(File)
      @file.stub!(:path).and_return(@old_path)
      @file.stub!(:close)
      FileUtils.stub!(:mkdir_p)
      FileUtils.stub!(:cp)
      FileUtils.stub!(:rm)
      FileUtils.stub!(:chmod)
      @attachment = mock('attachment')
    end

    it "should close the file" do
      @file.should_receive(:close)
      @storage.write(@path, @file, @attachment)
    end

    it "should create the directory tree" do
      FileUtils.should_receive(:mkdir_p).with('path/to')
      @storage.write(@path, @file, @attachment)
    end

    it "should copy the file to the new path" do
      FileUtils.should_receive(:cp).with(@old_path, @path)
      @storage.write(@path, @file, @attachment)
    end

    it "should remove the old file" do
      FileUtils.should_receive(:rm).with(@old_path)
      @storage.write(@path, @file, @attachment)
    end

    it "should set permissions on the new file" do
      FileUtils.should_receive(:chmod).with(0644, @path)
      @storage.write(@path, @file, @attachment)
    end
  end

  describe "delete" do
    before(:each) do
      FileUtils.stub!(:rm)
      @storage.stub!(:exists?).and_return(true)
    end

    it "should verify file exists" do
      @storage.should_receive(:exists?).with(@path)
      @storage.delete(@path)
    end

    it "should remove the file" do
      FileUtils.should_receive(:rm).with(@path)
      @storage.delete(@path)
    end

    it "should ignore file not found errors" do
      lambda {
        FileUtils.should_receive(:rm).and_raise(Errno::ENOENT)
        @storage.delete(@path)
      }.should_not raise_error
    end

    it "should not ignore other types of errors" do
      lambda {
        FileUtils.should_receive(:rm).and_raise("different error")
        @storage.delete(@path)
      }.should raise_error
    end
  end

  describe "public_url" do
    it "should be nil" do
      @storage.public_url.should be(nil)
    end
  end
end
