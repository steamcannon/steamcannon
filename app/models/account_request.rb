class AccountRequest < ActiveRecord::Base
  validates_presence_of :email

  before_create :create_token

  protected
  def create_token
    self.token = ActiveSupport::SecureRandom::hex(8) 
  end
end
