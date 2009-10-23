class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :role_id
  end

  def self.down
    remove_index :users, :role_id
  end
end