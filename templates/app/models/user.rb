class User < ActiveRecord::Base
  acts_as_authentic
  
  validates_presence_of :login, :email
   
   def deliver_verification_instructions!  
     reset_perishable_token!  
     NotifierMailer.deliver_verification_instructions(self)  
   end

   def verify!
     self.verified = true
     self.save
   end
    
end