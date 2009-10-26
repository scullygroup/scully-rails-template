class PublisherMailer < ActionMailer::Base
  default_url_options[:host] = "#{SITE_URL}"

  def approve_page(page, user)
    subject       "A Page Has Been Modified"
    from          "admin@scullytown.com"
    recipients    user.email
    sent_on       Time.now
    content_type  "text/html"
    body          :page => page
  end  

end
