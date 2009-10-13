class UserSession < Authlogic::Session::Base

  validate :check_if_verified

  private

  def check_if_verified
    errors.add(:base, "You have not yet verified your account") unless attempted_record && attempted_record.state == "confirmed"
  end
    
end