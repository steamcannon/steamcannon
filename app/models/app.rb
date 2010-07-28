class App < ActiveRecord::Base
  belongs_to :user
  has_many :app_versions
  has_many :deployments, :through => :app_versions
  attr_protected :user
  validates_presence_of :name
  accepts_nested_attributes_for :app_versions

  def latest_version
    app_versions.first(:order => 'version_number desc')
  end

  def latest_version_number
    latest_version ? latest_version.version_number : nil
  end
end
