require 'aasm'
class User < ActiveRecord::Base
  
  belongs_to :role
  
  acts_as_authentic
  
  validates_presence_of :login, :email
  
  attr_accessible :login, :email, :password, :password_confirmation, :role_id
    
  include AASM

  aasm_column :state

  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :confirmed
  aasm_state :denied

  aasm_event :confirm do
    transitions :to => :confirmed, :from => [:pending, :denied]
  end

  aasm_event :deny do
    transitions :to => :denied, :from => [:pending, :confirmed]
  end
  
  def deliver_verification_instructions!  
    reset_perishable_token!  
    NotifierMailer.deliver_verification_instructions(self)  
  end
  
end