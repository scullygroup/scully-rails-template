require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  setup :activate_authlogic

### Authorization Tests #########################################
  context "A user who is not logged-in" do
    setup do
      get :index
    end
    
    should_redirect_to("Login page") { '/user_sessions/new' }
  end

  context "A non-admin user accessing controller actions" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
      UserSession.create(@user)
      get :index
    end
    
    should_set_the_flash_to "You are not authorized to access this!"
    should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
  end
  
  context "A user who is not admin trying to access admin_data" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
      UserSession.create(@user)
      get '/admin_data'
    end
    
    should_set_the_flash_to "You are not authorized to access this!"
    should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
  end
#################################################################
  
  context "On INDEX" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      get :index
    end
    
    should_respond_with :success
    should_render_with_layout :comatose_admin
    should_render_template :index
  end
  
  context "On NEW" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      get :new
    end

    should_respond_with :success
    should_render_with_layout :comatose_admin
    should_render_template :new
  end
  
  context "On CREATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      post :create, :user => {
        :login                  => 'bobby',
        :email                  => 'bobby@example.com',
        :password               => '123456',
        :password_confirmation  => '123456'
      }
    end
    
    should_change("Number of users") { User.count }
    should_set_the_flash_to "Thanks for signing up, we've delivered an email to you with instructions on how to complete your registration!"
    should_redirect_to('Users list') { '/users' }
    
    should "send verification email" do
      assert_sent_email do |email|
        email.content_type = 'text/html; charset=utf-8'
        email.from = 'admin@scullytown.com'
        email.to = @user.email
        email.subject = "Email Verification"
        email.date = Time.now
      end
    end
  end
  
  context "On failed CREATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      post :create, :user => {
        :login                  => nil,
        :email                  => nil,
        :password               => nil,
        :password_confirmation  => nil
      }
    end

    should_render_template :new
  end
  
  context "On SHOW" do
    context "a user accessesing their own profile" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :show, :id => Factory(:user).id
      end
    
      should_respond_with :success
      should_render_with_layout :comatose_admin
      should_render_template :show
    end
    
    context "an admin accessesing a user's profile" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :show, :id => Factory(:user).id
      end
    
      should_respond_with :success
      should_render_with_layout :comatose_admin
      should_render_template :show
    end
    
    context "a user accessesing another profile" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
        UserSession.create(@user)
        get :show, :id => Factory(:user).id
      end
    
      should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
    end
  end
  
  context "On EDIT" do
    context "an admin accessesing a user's profile" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :edit, :id => Factory(:user).id
      end
    
      should_respond_with :success
      should_render_with_layout :comatose_admin
      should_render_template :edit
    end
    
    context "a user accessesing their own profile" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
        UserSession.create(@user)
        get :edit, :id => @user.id
      end
    
      should_respond_with :success
      should_render_with_layout :comatose_admin
      should_render_template :edit
    end
    
    context "a user accessesing another user's profile" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
        UserSession.create(@user)
        get :edit, :id => Factory(:user).id
      end
      
      should_set_the_flash_to "You cannot access records outside of your account!"
      should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
    end
  end

  context "On UPDATE" do
    context "if admin" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        put :update, :id => Factory(:user).to_param, :user => { }
      end
    
      should_set_the_flash_to "Account updated!"
      should_redirect_to('Users list') { '/users' }
    end
    
    context "if non-admin" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
        UserSession.create(@user)
        put :update, :id => @user.to_param, :user => { }
      end
    
      should_set_the_flash_to "Account updated!"
      should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
    end
  end
  
  context "On failed UPDATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      User.any_instance.stubs(:save).returns(false)
      put :update, :id => Factory(:user).to_param, :user => { }
    end

    should_render_template :edit
  end
  
  context "On DESTROY" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      @old_user = Factory.create(:user, :login => 'olduser', :password => '123456')
      post :destroy, :id => @old_user.id
    end
    
    should_set_the_flash_to "Account has been deleted"
    should_redirect_to("Users list") { '/users' }
    should_change("Number of users") { User.count }
  end
  
end