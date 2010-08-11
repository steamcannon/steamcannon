class AddAuditColumnsToInstance < ActiveRecord::Migration
  def self.up
    add_column :instances, :started_at, :datetime
    add_column :instances, :started_by, :integer
    add_column :instances, :stopped_at, :datetime
    add_column :instances, :stopped_by, :integer
  end

  def self.down
    remove_column :instances, :stopped_by
    remove_column :instances, :stopped_at
    remove_column :instances, :started_by
    remove_column :instances, :started_at
  end
end
