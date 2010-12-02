class AddMetadataToEventSubject < ActiveRecord::Migration
  def self.up
    add_column :event_subjects, :metadata, :text
  end

  def self.down
    remove_column :event_subjects, :metadata
  end
end
