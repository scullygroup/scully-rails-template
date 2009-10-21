require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  should_belong_to :role
  should_validate_presence_of :login, :email
  
  should_allow_mass_assignment_of :login, :email, :password, :password_confirmation
      
  context "After signing up a user" do  
    setup do
      @user = Factory.create(:user, 
                            :login => "hankhill", 
                            :password => '123456', 
                            :password_confirmation => '123456',
                            :email => 'hank@example.com')
    end
    
    should_create :user
    
    should "be in a state of pending" do
      assert_equal "pending", @user.state
    end
  end
  
  context "When confirming the validation email, clicking confirm" do
    setup do
      @user = Factory.build(:user, :state => 'pending')
      @user.confirm!
    end
    
    should "confirm user" do
      assert_equal "confirmed", @user.state
    end
  end
  
  context "When denying a user, clicking deny" do
    setup do
      @user = Factory.build(:user, :state => 'confirmed')
      @user.deny!
    end
    
    should "deny the user" do
      assert_equal "denied", @user.state
    end
  end
  
end