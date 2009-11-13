require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  
  setup :activate_authlogic
  
  context "An unauthenticated user" do
    setup do
      @user = Factory.build(:user, :login => 'baduser', :password => 'none', :state => 'confirmed')
      get :index
    end
    
    should_redirect_to("Login page") { '/user_sessions/new' }
  end
  
  context "An unauthorized user" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "publisher").id)
      UserSession.create(@user)
      get :index
    end
    
    should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
  end
  
  context "A user who has not been confirmed" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'pending', :role_id => Factory(:role, :name => "admin").id)
      get :index
    end
    
    should_redirect_to("Login page") { '/user_sessions/new' }
  end
  
  context "A user who has been denied" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'denied', :role_id => Factory(:role, :name => "admin").id)
      get :index
    end
    
    should_redirect_to("Login page") { '/user_sessions/new' }
  end
  
  context "On accessing INDEX" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      get :index
    end
    
    should_respond_with :success
    should_render_with_layout :comatose_admin
    should_render_template :index
  end
  
  context "On NEW" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      get :new
    end

    should_respond_with :success
    should_render_with_layout :comatose_admin
    should_render_template :new
  end
  
  context "On CREATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      post :create, :role => { :name => 'writer' }
    end
    
    should_change("Number of roles") { User.count }
    should_set_the_flash_to "Role was sucessfully saved!"
    should_redirect_to('Roles list') { '/roles' }
  end
  
  context "On failed CREATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      post :create, :role => {:name => nil}
    end

    should_render_template :new
  end
  
  context "On EDIT" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      get :edit, :id => Factory(:role).id
    end
    
    should_respond_with :success
    should_render_with_layout :comatose_admin
    should_render_template :edit
  end

  context "On UPDATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      put :update, :id => Factory(:role).to_param, :role => { }
    end
    
    should_set_the_flash_to "Role updated!"
    should_redirect_to('Roles list') { '/roles' }
  end
  
  context "On failed UPDATE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      Role.any_instance.stubs(:save).returns(false)
      put :update, :id => Factory(:role).to_param, :role => { }
    end

    should_render_template :edit
  end
  
  context "On DESTROY" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admin").id)
      UserSession.create(@user)
      post :destroy, :id => Factory(:role).id
    end
    
    should_set_the_flash_to "Role has been deleted"
    should_redirect_to("Roles list") { '/roles' }
    should_change("Number of Roles") { Role.count }
  end
  
end