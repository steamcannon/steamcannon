class RemoveUserSshKeyNameDefault < ActiveRecord::Migration
  def self.up
    change_column_default :users, :ssh_key_name, nil
  end

  def self.down
    change_column_default :users, :ssh_key_name, 'default'
  end
end
