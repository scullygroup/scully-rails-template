class NotifierMailer < ActionMailer::Base

  default_url_options[:host] = "#{SITE_URL}"  

  def verification_instructions(user)
    subject       "Email Verification"
    from          "admin@scullytown.com"
    recipients    user.email
    sent_on       Time.now
    body          :verification_url => user_verification_url(user.perishable_token)
  end

end