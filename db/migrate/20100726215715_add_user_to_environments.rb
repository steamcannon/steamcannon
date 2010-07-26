class AddUserToEnvironments < ActiveRecord::Migration
  def self.up
    add_column :environments, :user_id, :integer
  end

  def self.down
    remove_column :environments, :user_id
  end
end
