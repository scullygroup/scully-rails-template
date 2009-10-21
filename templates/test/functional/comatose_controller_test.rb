require 'test_helper'

class ComatoseControllerTest < ActionController::TestCase
  
  setup :activate_authlogic
  
  context "On SHOW" do
    context "for a page that is approved" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        get :show, :page => Factory(:comatose_page, :state => 'approved').full_path, :index => ''
      end
  
      should_respond_with_content_type 'text/html'
    end
    
    context "for a page that is pending (showing previous version)" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
        UserSession.create(@user)
        @page = Factory(:comatose_page, 
          :parent_id         => 1,
          :full_path         => 'contact-us',
          :title             => 'Contact Us',
          :slug              => 'contact-us',
          :keywords          => 'blah-blah',
          :body              => 'Lorem ipsum dolor sit amet, consectetur adipisicing',
          :version           => 1,
          :role_id           => 1,
          :state             => 'pending'
        )
        get :show, :page => @page.full_path, :index => ''
      end
  
      should_respond_with_content_type 'text/html'
    end
  end

end