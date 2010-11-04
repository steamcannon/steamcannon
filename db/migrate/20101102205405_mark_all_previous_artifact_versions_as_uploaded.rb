class ArtifactVersion < ActiveRecord::Base
end

class MarkAllPreviousArtifactVersionsAsUploaded < ActiveRecord::Migration
  def self.up
    ArtifactVersion.all.each do |artifact_version|
      artifact_version.update_attributes(:current_state => 'uploaded')
    end
  end

  def self.down
    ArtifactVersion.all.each do |artifact_version|
      artifact_version.update_attributes(:current_state => nil)
    end
  end
end
