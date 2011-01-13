class StoreBucketNamesOnCloudProfiles < ActiveRecord::Migration
  def self.up
    # store old-style bucket names for artifacts and environments so we
    # can still access them
    CloudProfile.all.each do |cp|
      if cp.username and !cp.metadata[:s3_artifact_bucket_name] and cp.provider_name == 'us-east-1'
        sc_salt = Digest::SHA1.hexdigest(Certificate.ca_certificate.certificate)
        creds_salt = Digest::SHA1.hexdigest(cp.username)
        suffix = Digest::SHA1.hexdigest("#{sc_salt} #{creds_salt}")
        cp.merge_and_update_metadata(:s3_artifact_bucket_name => "SteamCannonArtifacts_#{suffix}",
                                     :s3_environment_bucket_name => "SteamCannonEnvironments_#{suffix}")
      end
    end
  end

  def self.down
  end
end
