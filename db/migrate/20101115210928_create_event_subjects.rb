class CreateEventSubjects < ActiveRecord::Migration
  def self.up
    create_table :event_subjects do |t|
      t.string :subject_type
      t.integer :subject_id
      t.string :owner_type
      t.integer :owner_id
      t.string :name

      t.string :ancestry

      t.timestamps
    end
  end

  def self.down
    drop_table :event_subjects
  end
end
