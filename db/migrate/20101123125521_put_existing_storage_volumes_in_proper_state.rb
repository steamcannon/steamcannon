class StorageVolume < ActiveRecord::Base
end

class PutExistingStorageVolumesInProperState < ActiveRecord::Migration
  def self.up
    StorageVolume.all.each do |sv|
      state = nil
      state = 'attached' if sv.cloud_volume_is_attached?
      state ||= 'available' if sv.cloud_volume_is_available?
      state ||= 'not_found' unless sv.cloud_volume_exists?
      unless state
        puts ">> StorageVolume##{sv.id} is not in a known state!"
        exit
      end
      puts ">> putting StorageVolume##{sv.id} in :#{state} state"
      sv.update_attribute(:current_state, state)
    end
  end

  def self.down
  end
end
