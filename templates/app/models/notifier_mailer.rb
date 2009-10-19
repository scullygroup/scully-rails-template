# this file is new for email verification

class NotifierMailer < ActionMailer::Base

  default_url_options[:host] = "#{SITE_URL}"  

  def verification_instructions(user)
    subject       "Email Verification"
    from          "admin@scullytown.com"
    recipients    user.email
    sent_on       Time.now
    content_type  "text/html"
    body          :verification_url => user_verification_url(user.perishable_token)
  end

end