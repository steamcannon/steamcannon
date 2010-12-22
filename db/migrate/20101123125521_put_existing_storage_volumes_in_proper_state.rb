class StorageVolume < ActiveRecord::Base
  belongs_to :instance
end

class PutExistingStorageVolumesInProperState < ActiveRecord::Migration
  def self.up
    StorageVolume.all.each do |sv|
      if sv.instance && sv.instance.running?
        state = 'attached'
      else
        state = 'available' 
      end
      puts ">> putting StorageVolume##{sv.id} in :#{state} state"
      sv.update_attribute(:current_state, state)
    end
  end

  def self.down
  end
end
