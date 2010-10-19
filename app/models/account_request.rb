class AccountRequest < ActiveRecord::Base
  include AASM
  
  validates_presence_of :email

  before_create :create_token

  aasm_column :current_state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :invited
  aasm_state :ignored
  aasm_state :accepted

  aasm_event :invite do
    transitions :to => :invited, :from => [:pending, :invited]
  end

  aasm_event :ignore do
    transitions :to => :ignored, :from => :pending
  end
  
  aasm_event :accept do
    transitions :to => :accepted, :from => :invited
  end
  
  def send_invitation(host, from)
    ModelTask.async(self, :_send_invitation, host, from)
    invite!
  end
  
  protected
  def create_token
    self.token = ActiveSupport::SecureRandom::hex(8) 
  end

  def _send_invitation(host, from)
    AccountRequestMailer.deliver_invitation(host, from, email, token)
  end

end
