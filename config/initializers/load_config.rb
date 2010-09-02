# set defaults 
APP_CONFIG = { :use_ssl_with_agents => true }
APP_CONFIG.merge!(begin
                    YAML.load_file("#{RAILS_ROOT}/config/steamcannon.yml")
                  rescue
                    {}
                  end)
