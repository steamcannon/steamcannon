module Cloud
  class Deltacloud

    def initialize(cloud_username, cloud_password)
      @cloud_username = cloud_username
      @cloud_password = cloud_password
    end

    def instances
      select_instances.map do |i|
        Instance.new(
                     :id            => i.id,
                     :image_id      => i.image.id,
# TODO: support this -->                     :key_pair_name => i.key_pair,
                     :public_dns    => i.public_addresses.first,
                     :status        => i.state.downcase
                     )
      end
    end

    def select_instances
      client.instances.select{|x| APP_CONFIG['image_ids'].include?(x.image.id)}
    end

    def launch image_id, key_pair_name
      client.create_instance(image_id,
                             :keyname => key_pair_name,
                             :user_data => Base64.encode64(user_data))
    end

    def terminate instance_id
      i = client.instance(instance_id)
      i.stop!
    end

    def client
      @client ||= DeltaCloud.new(cloud_username, cloud_password, APP_CONFIG['deltacloud_url'])
    end

    def user_data(bucket)
      Base64.encode64(["access_key: #{@cloud_username}",
                       "secret_access_key: #{@cloud_password}",
                       "bucket: #{bucket}"
                      ].join("\n"))
    end

  end
end
