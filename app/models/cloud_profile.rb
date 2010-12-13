class CloudProfile < ActiveRecord::Base
  belongs_to :organization

  before_save :encrypt_password

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :organization_id
  
  validate :validate_cloud_credentials

  attr_accessor_with_default :password_dirty, false
  attr_accessor_with_default( :password ) do
    (@password_dirty or self.crypted_password.blank?) ? @password : Certificate.decrypt(self.crypted_password)
  end

  def obfuscated_password
    obfuscated = password ? password.dup : ''
    if obfuscated.length < 6
      obfuscated = '******'
    else
      obfuscated[0..-5] = '*' * (password.length-4)
    end
    obfuscated
  end

  def password=(pw)
    @password_dirty = true
    @password = pw
  end

  def cloud
    @cloud ||= Cloud::Deltacloud.new(username, password, cloud_name, provider_name)
  end

  def cloud_specific_hacks
    @cloud_hacks ||= "Cloud::#{cloud_name.camelize}".constantize.new(self)
  end

  def environment_bucket_name
    cloud_specific_hacks.unique_bucket_name("SteamCannonEnvironments_")
  end

  def artifact_bucket_name
    cloud_specific_hacks.unique_bucket_name("SteamCannonArtifacts_")
  end

  protected
  def encrypt_password
    if @password_dirty || (new_record? && !@password.blank?)
      self.crypted_password = Certificate.encrypt(@password)
    end
  end

  def validate_cloud_credentials
    if username_changed? or @password_dirty
      message = "Cloud credentials are invalid"
      errors.add_to_base(message) unless cloud.valid_credentials?
    end
  end
end
