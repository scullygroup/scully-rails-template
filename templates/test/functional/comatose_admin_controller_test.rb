require 'test_helper'

class ComatoseAdminControllerTest < ActionController::TestCase
  
  setup :activate_authlogic
  
  context "On APPROVE" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      get :approve, :id => Factory(:comatose_page).id
    end
    
    should_set_the_flash_to "Page has been approved!"
    should_redirect_to ("Admin page") { '/admin' }
  end
  
  context "On DENY" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      get :deny, :id => Factory(:comatose_page).id
    end
    
    should_set_the_flash_to "Page has been denied!"
    should_redirect_to ("Admin page") { '/admin' }
  end
  
  context "When creating a new page" do
    setup do
      @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed')
      UserSession.create(@user)
      post :new, :page => {
        :parent_id    => 1,
        :full_path    => 'my-page',
        :title        => 'My Page',
        :slug         => 'my-page',
        :body         => 'Lorem ipsum'
      }
    end
    
    should_set_the_flash_to "The page 'My Page' has been created and is awaiting approval"
  end
  
  context "When updating a page" do
    context "as a custom writer who is not supposed to access that page" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "admissions").id)
        UserSession.create(@user)
        post :edit, :id => Factory(:comatose_page, :role_id => 1).to_param, :page => { }
      end
      
      should_set_the_flash_to "The requested record was not found under your account!"
      should_redirect_to("The Users profile page") { "/account/#{@user.id}" }
    end
    
    context "as an admin" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => 1)
        UserSession.create(@user)
        post :edit, :id => Factory(:comatose_page).to_param, :page => { }
      end

      should_set_the_flash_to "Saved changes to 'Contact Us'"  
    end
    
    context "as a writer" do
      setup do
        @user = Factory.build(:user, :login => 'bcalloway', :password => '123456', :state => 'confirmed', :role_id => Factory(:role, :name => "writer").id)
        UserSession.create(@user)
        post :edit, :id => Factory(:comatose_page).to_param, :page => { }
      end

      should_set_the_flash_to "Changes to 'Contact Us' have been submitted to a Publisher for review"

      should "send email to publisher" do
        assert_sent_email do |email|
          email.content_type = 'text/html; charset=utf-8'
          email.from = 'admin@scullytown.com'
          email.to = Factory(:user).email
          email.subject = "A Page Has Been Modified"
          email.date = Time.now
          email.body.include?('Please login to approve or deny the update')
        end
      end
    end
  end
  
end