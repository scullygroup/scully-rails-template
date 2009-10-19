class Role < ActiveRecord::Base
  has_many :users
  has_many :comatose_pages
  
  validates_presence_of :name
  
  before_create :lowercase_role
  
  def lowercase_role
    self.name = name.downcase
  end
  
  def self.list_all_but_reserved
    Role.name_not_like_all("admin", "publisher", "writer", "user")
  end
  
end