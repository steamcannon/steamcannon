class AddAncestryIndexToEventSubject < ActiveRecord::Migration
  def self.up
    add_index :event_subjects, :ancestry
  end

  def self.down
  end
end
