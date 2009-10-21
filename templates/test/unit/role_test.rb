require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  should_have_many :users
  should_have_many :comatose_pages
  
  should_validate_presence_of :name
  
  should_allow_mass_assignment_of :name
  
  context "A role name" do
    setup do
      @role = Factory.create(:role, :name => 'Admissions')
    end
    
    should "be lowercase" do
      assert_equal "admissions", @role.name
    end
  end

end