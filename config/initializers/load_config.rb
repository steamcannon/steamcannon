
INSTANCE_FACTORY = EC2.new

APP_CONFIG = YAML.load_file("#{ENV['HOME']}/.cooling-tower/config.yml")

# User data for management instance
user_data = %w{access_key secret_access_key bucket}.map{|x| "#{x}: #{APP_CONFIG[x]}"}.join("\n")
APP_CONFIG['user_data'] = Base64.encode64(user_data)
