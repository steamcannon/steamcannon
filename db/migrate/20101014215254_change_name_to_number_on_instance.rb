class ChangeNameToNumberOnInstance < ActiveRecord::Migration
  def self.up
    remove_column :instances, :name
    add_column :instances, :number, :integer
  end

  def self.down
    add_column :instances, :name, :string
    remove_column :instances, :number
  end
end
