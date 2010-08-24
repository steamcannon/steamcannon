module Cloud
  class Deltacloud

    def initialize(cloud_username, cloud_password)
      @cloud_username = cloud_username
      @cloud_password = cloud_password
    end

    def instance(id)
      client.instance(id)
    end

    def instances
      client.instances
    end

    def launch(image_id, bucket)
      client.create_instance(image_id,
                             :user_data => Base64.encode64(user_data(bucket)))
    end

    def terminate instance_id
      i = client.instance(instance_id)
      i.stop!
    end

    def hardware_profiles
      @hardware_profiles ||= client.hardware_profiles.map(&:name)
    end

    def client
      @client ||= DeltaCloud.new(@cloud_username, @cloud_password, APP_CONFIG['deltacloud_url'])
    end

    def user_data(bucket)
      Base64.encode64(["access_key: #{@cloud_username}",
                       "secret_access_key: #{@cloud_password}",
                       "bucket: #{bucket}"
                      ].join("\n"))
    end

  end
end
