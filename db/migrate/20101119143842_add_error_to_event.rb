class Event < ActiveRecord::Base
end

class AddErrorToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :error, :text
    Event.reset_column_information
  end

  def self.down
    remove_column :events, :error
    Event.reset_column_information
  end
end
