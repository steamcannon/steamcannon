
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/cooling-tower.yml")

# We shouldn't mess with instances we're not configured to care about
APP_CONFIG['image_ids'] = APP_CONFIG.entries.select{|x,y| x.ends_with? 'image_id'}.map{|x,y| y}
