class AddCanScaleOutToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :can_scale_out, :boolean, :default => false
  end

  def self.down
    remove_column :images, :can_scale_out
  end
end
