class Role < ActiveRecord::Base
  has_many :users
  has_many :comatose_pages
  
  validates_presence_of :name
  
  before_create :lowercase_role
  
  attr_accessible :name
  
  def lowercase_role
    self.name = name.downcase
  end
  
  # Only show custom writer-level roles, prevents an admin from changing default system roles
  def self.list_all_but_reserved
    Role.name_does_not_equal_all("admin", "publisher", "writer", "user")
  end
  
end