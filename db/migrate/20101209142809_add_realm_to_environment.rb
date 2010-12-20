class Environment < ActiveRecord::Base
end

class AddRealmToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :realm, :string
    Environment.reset_column_information
  end

  def self.down
    remove_column :environments, :realm
    Environment.reset_column_information
  end
end
