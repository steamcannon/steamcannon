class AccountRequestMailer < ActionMailer::Base
  

  def invitation(host, sender, to, token)
    subject    "[SteamCannon] your request for an account has been accepted"
    recipients to
    from       sender
    
    body       :url => new_user_url(:host => host, :token => token)
  end

end
