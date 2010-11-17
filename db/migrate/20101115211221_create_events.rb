class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :event_subject_id
      t.string :operation
      t.string :status
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
