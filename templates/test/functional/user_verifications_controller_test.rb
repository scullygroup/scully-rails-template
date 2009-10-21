require 'test_helper'

class UserVerificationsControllerTest < ActionController::TestCase

  setup :activate_authlogic
  
  context "On SHOW" do
    setup do
      get :show, :id => Factory(:user).perishable_token
    end

    should_set_the_flash_to "Thank you for verifying your account. You may now login."
    should_redirect_to("Login page") { '/login' }
  end
  
  context "On CONFIRM" do
    context "for another user" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :confirm, :id => Factory(:user).id
      end
    
      should_redirect_to("Users list") { '/users' }
    end
    
    context "for yourself" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :confirm, :id => @user.id
      end
    
      should_set_the_flash_to "You cannot confirm your own account!"
    end
  end
  
  context "On DENY" do
    context "for another user" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :deny, :id => Factory(:user).id
      end
    
      should_redirect_to("Users list") { '/users' }
    end
    
    context "for yourself" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :deny, :id => @user.id
      end
    
      should_set_the_flash_to "You cannot deny your own account!"
    end
  end
end