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

describe ArtifactVersion do
  before(:each) do
    @valid_attributes = {
      :artifact_id => 1,
      :version_number => 1,
      :archive_file_name => "value for archive_file_name",
      :archive_content_type => "value for archive_content_type",
      :archive_file_size => "value for archive_file_size",
      :archive_updated_at => "value for archive_updated_at"
    }
  end

  it "should create a new instance given valid attributes" do
    artifact_version = ArtifactVersion.new(@valid_attributes)
    artifact_version.stub!(:assign_version_number)
    artifact_version.save!
  end

  it "should belong to an artifact" do
    ArtifactVersion.new.should respond_to(:artifact)
  end

  it "should assign a version number before creating" do
    artifact_version = ArtifactVersion.new(@valid_attributes)
    artifact_version.should_receive(:assign_version_number)
    artifact_version.save!
  end

  it "should assign 1 as the first version number" do
    artifact = mock_model(Artifact, :latest_version_number => nil)
    artifact_version = ArtifactVersion.new(@valid_attributes)
    artifact_version.stub!(:artifact).and_return(artifact)
    artifact_version.save!
    artifact_version.version_number.should be(1)
  end

  it "should return artifact's name and version as to_s" do
    artifact = Artifact.new(:name => "test artifact")
    artifact_version = ArtifactVersion.new
    artifact_version.artifact = artifact
    artifact_version.version_number = 2
    artifact_version.to_s.should eql("test artifact v2")
  end

  describe "pull deployment" do
    before(:each) do
      @artifact_version = Factory.build(:artifact_version)
      @storage = mock('storage')
      @artifact_version.stub!(:storage).and_return(@storage)
    end

    it "should support pull deployment if archive has public url" do
      @storage.stub!(:public_url).and_return('public_url')
      @artifact_version.supports_pull_deployment?.should be(true)
    end

    it "should not support pull deployment if archive has no public url" do
      @storage.stub!(:public_url).and_return(nil)
      @artifact_version.supports_pull_deployment?.should be(false)
    end

    it "should return archive's public url as pull deployment url" do
      @storage.stub!(:public_url).and_return('public_url')
      @artifact_version.pull_deployment_url.should == 'public_url'
    end
  end

  it "should get deployment file from archive" do
    archive = mock('archive')
    archive.should_receive(:to_file).and_return('the_file')
    artifact_version = Factory.build(:artifact_version)
    artifact_version.should_receive(:archive).and_return(archive)
    artifact_version.deployment_file.should == 'the_file'
  end

  describe "is_deployed?" do
    before(:each) do
      @artifact_version = ArtifactVersion.new
      @deployment = mock(Deployment)
      @artifact_version.stub!(:deployments).and_return([@deployment])
    end

    it "should return true if any deployments claim to be deployed" do
      @deployment.should_receive(:is_deployed?).and_return(true)
      @artifact_version.is_deployed?.should be_true
    end

    it "should return false if no deployments claim to be deployed" do
      @deployment.should_receive(:is_deployed?).and_return(false)
      @artifact_version.is_deployed?.should_not be_true
    end
  end

  describe "upload_archive_async" do
    it "should create an async task" do
      artifact_version = Factory(:artifact_version)
      ModelTask.should_receive(:async).with(artifact_version, :upload_archive)
      artifact_version.send(:upload_archive_async)
    end
  end

  describe "upload_archive" do
    before(:each) do
      @artifact_version = Factory(:artifact_version)
      @storage = mock('storage')
      @storage.stub!(:write)
      @artifact_version.stub!(:storage).and_return(@storage)
      @artifact_version.stub!(:remove_local_archive)
    end

    it "should write to cloud storage" do
      @storage.should_receive(:write).with(@artifact_version)
      @artifact_version.send(:upload_archive)
    end

    it "should remove local archive" do
      @artifact_version.should_receive(:remove_local_archive)
      @artifact_version.send(:upload_archive)
    end

    it "should transition to uploaded on success" do
      @artifact_version.send(:upload_archive)
      @artifact_version.should be_uploaded
    end

    it "should transition to upload_failed on error" do
      @storage.should_receive(:write).and_raise('error')
      @artifact_version.send(:upload_archive)
      @artifact_version.should be_upload_failed
    end
  end

  describe "remove_archive" do
    before(:each) do
      @artifact_version = Factory(:artifact_version)
      @artifact_version.stub!(:remove_local_archive)
      @artifact_version.stub!(:remove_cloud_archive)
    end

    it "should remove local archive" do
      @artifact_version.should_receive(:remove_local_archive)
      @artifact_version.send(:remove_archive)
    end

    it "should remove cloud archive" do
      @artifact_version.should_receive(:remove_cloud_archive)
      @artifact_version.send(:remove_archive)
    end
  end

  describe "remove_local_archive" do
    before(:each) do
      @artifact_version = Factory(:artifact_version)
      @archive = mock('archive', :path => 'path')
      @artifact_version.should_receive(:archive).and_return(@archive)
    end

    it "should remove the file" do
      FileUtils.should_receive(:rm).with('path')
      @artifact_version.send(:remove_local_archive)
    end

    it "should ignore file not found errors" do
      FileUtils.should_receive(:rm).with('path').and_raise(Errno::ENOENT.new)
      lambda {
        @artifact_version.send(:remove_local_archive)
      }.should_not raise_error
    end

    it "should not ignore other errors" do
      FileUtils.should_receive(:rm).with('path').and_raise('error')
      lambda {
        @artifact_version.send(:remove_local_archive)
      }.should raise_error
    end
  end

  describe "remove_cloud_archive" do
    before(:each) do
      @artifact_version = Factory(:artifact_version)
      @storage = mock('storage')
      @artifact_version.stub!(:storage).and_return(@storage)
    end

    it "should delete from cloud storage" do
      @storage.should_receive(:delete).with(@artifact_version)
      @artifact_version.send(:remove_cloud_archive)
    end
  end

  describe "storage" do
    before(:each) do
      @artifact_version = Factory(:artifact_version)
      @user = Factory(:user)
      @artifact_version.stub_chain(:artifact, :user).and_return(@user)
      @cloud = mock('cloud')
      @user.stub!(:cloud).and_return(@cloud)
    end

    it "should create class from cloud name" do
      @cloud.should_receive(:name).at_least(:once).and_return('ec2')
      Cloud::Storage::Ec2Storage.should_receive(:new)
      @artifact_version.send(:storage)
    end
  end
end
