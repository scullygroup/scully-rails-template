require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  setup :activate_authlogic
  
  context "On NEW" do
    setup do
      get :new
    end

    should_respond_with :success
    should_render_template :new
  end
  
  context "On CREATE" do
    setup do
      post :create, :user_session => Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
    end
    
    should_set_the_flash_to "Login successful!"
    should_redirect_to('Users list') { '/admin' }
  end
  
  context "On failed CREATE" do
    setup do
      post :create, :user_session => {
        :login      => nil,
        :password   => nil
      }
    end

    should_render_template :new
  end
  
  context "On DESTROY" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      post :destroy
    end
    
    should_set_the_flash_to "Logout successful!"
    should_redirect_to("Users list") { '/' }
  end
  
end
