
INSTANCE_FACTORY = EC2.new

APP_CONFIG = YAML.load_file("#{ENV['HOME']}/.cooling-tower/config.yml")

# User data for management instance
user_data = %w{access_key secret_access_key bucket}.map{|x| "#{x}: #{APP_CONFIG[x]}"}.join("\n")
APP_CONFIG['user_data'] = Base64.encode64(user_data)

# We shouldn't mess with instances we're not configured to care about
APP_CONFIG['image_ids'] = APP_CONFIG.entries.select{|x,y| x.ends_with? 'image_id'}.map{|x,y| y}
