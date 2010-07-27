class AppVersion < ActiveRecord::Base
  belongs_to :app
  has_many :deployments
  has_attached_file(:archive,
                    :url => "/uploads/:id/:filename",
                    :path => ":rails_root/public/uploads/:id/:filename")
  validates_attachment_presence :archive
  validates_presence_of :app_id
  attr_protected :version_number, :app
  before_create :assign_version_number

  def assign_version_number
    self.version_number = (self.app.latest_version_number || 0) + 1
  end

  def to_s
    "#{app.name} version #{version_number}"
  end
end
