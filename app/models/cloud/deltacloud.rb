module Cloud
  class Deltacloud

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
      client.create_instance(image_id, :key_name => key_pair_name, :user_data => APP_CONFIG['user_data'])
    end

    def terminate instance_id
      i = client.instance(instance_id)
      i.stop!
    end

    def client
      @client ||= DeltaCloud.new(APP_CONFIG['access_key'], APP_CONFIG['secret_access_key'], APP_CONFIG['deltacloud_url'])
    end

  end
end
