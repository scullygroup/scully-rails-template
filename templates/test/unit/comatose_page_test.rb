require 'test_helper'

class ComatosePageTest < ActiveSupport::TestCase
  
  setup :activate_authlogic
  
  context "After creating a new page" do  
    setup do
      @page = Factory(:comatose_page)
    end
    
    should_create :comatose_page
    
    should "be in a state of pending" do
      assert_equal "pending", @page.state
    end
  end
  
  context "When approving a page, clicking approve" do
    setup do
      @page = Factory.build(:comatose_page, :state => 'pending')
      @page.approve!
    end
  
    should "confirm page" do
      assert_equal "approved", @page.state
    end
  end

  context "When denying a page, clicking deny" do
    setup do
      @page = Factory.build(:comatose_page, :state => 'pending')
      @page.deny!
    end
  
    should "deny page" do
      assert_equal "denied", @page.state
    end
  end
end