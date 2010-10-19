class AccountRequest < ActiveRecord::Base
  validates_presence_of :email

  before_create :create_token

  def send_invitation(host, from)
    ModelTask.async(self, :_send_invitation, host, from)
  end
  
  protected
  def create_token
    self.token = ActiveSupport::SecureRandom::hex(8) 
  end

  def _send_invitation(host, from)
    AccountRequestMailer.deliver_invitation(host, from, email, token)
  end

end
