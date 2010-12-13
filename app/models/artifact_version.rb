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


class ArtifactVersion < ActiveRecord::Base
  include AASM

  TYPES = [
    :ear, :war, :jar, :rails, :rack, :datasource, :other
  ]

  TYPE_DESCRIPTIONS = {
    :ear => 'Java Enterprise Application Archive',
    :war => 'Java Web Application Archive',
    :jar => 'Java Archive',
    :rails => 'Rails Archive',
    :rack => 'Rack Archive',
    :datasource => 'Datasource',
    :other => 'Other',
  }

  belongs_to :artifact
  has_many :deployments, :dependent => :destroy

  before_create :assign_version_number
  after_create :upload!
  # This before_destroy must come before has_attached_file
  before_destroy :remove_archive

  has_attached_file(:archive,
                    :path => ":rails_root/tmp/artifact_versions/:id")
  validates_attachment_presence :archive
  attr_protected :version_number, :artifact

  default_scope :order => 'version_number DESC'

  aasm_column :current_state
  aasm_initial_state :staging
  aasm_state :staging
  aasm_state :uploading, :enter => :upload_archive_async
  aasm_state :uploaded
  aasm_state :upload_failed

  aasm_event :upload, :error => :upload_error_raised do
    transitions :to => :uploading, :from => :staging
  end

  aasm_event :uploaded, :error => :upload_error_raised do
    transitions :to => :uploaded, :from => :uploading
  end

  aasm_event :upload_failed do
    transitions :to => :upload_failed, :from => [:staging, :uploading]
  end

  def to_s
    "#{artifact.name} v#{version_number}"
  end

  def supports_pull_deployment?
    !public_url.blank?
  end

  def pull_deployment_url
    public_url
  end

  def deployment_file
    archive.to_file
  end

  def type_key
    case ( archive_file_name )
      when /\.ear$/
        :ear
      when /\.war$/
        :war
      when /\.jar$/
        :jar
      when /\.rails$/
        :rails
      when /\.rack$/
        :rack
      when /\-ds.xml$/
        :datasource
      else
        :other
    end
  end

  def type_description
    TYPE_DESCRIPTIONS[type_key]
  end

  def application?
    [ :ear, :war, :rails, :rack ].include?(type_key)
  end

  def is_deployed?
    deployments.any?(&:is_deployed?)
  end

  def public_url
    storage.public_url(self)
  end

  protected

  def assign_version_number
    self.version_number = (self.artifact.latest_version_number || 0) + 1
  end

  def upload_error_raised(error)
    logger.error("Error uploading artifact: #{error.inspect}\n#{error.backtrace}")
    upload_failed!
  end

  def upload_archive_async
    ModelTask.async(self, :upload_archive)
  end

  def upload_archive
    storage.write(self)
    remove_local_archive
    uploaded!
  rescue => e
    upload_error_raised(e)
  end

  def remove_archive
    remove_local_archive
    remove_cloud_archive
  end

  def remove_local_archive
    FileUtils.rm(archive.path)
  rescue Errno::ENOENT
    # Ignore errors if the file doesn't exist or was already deleted
  end

  def remove_cloud_archive
    storage.delete(self)
  rescue => error
    # Log but ignore any errors when trying to remove from cloud
    logger.error("Error removing artifact from cloud: #{error.inspect}\n#{error.backtrace}")
  end

  def storage
    cloud_profile = artifact.cloud_profile
    storage_class = "Cloud::Storage::#{cloud_profile.cloud_name.camelize}Storage".constantize
    storage_class.new(cloud_profile.username,
                      cloud_profile.password,
                      cloud_profile.cloud_specific_hacks)
  end
end
