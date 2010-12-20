class EventSubject < ActiveRecord::Base
end

class AddMetadataToEventSubject < ActiveRecord::Migration
  def self.up
    add_column :event_subjects, :metadata, :text
    EventSubject.reset_column_information
  end

  def self.down
    remove_column :event_subjects, :metadata
    EventSubject.reset_column_information
  end
end
