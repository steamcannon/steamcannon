# set defaults 
APP_CONFIG = { }
APP_CONFIG.merge!(begin
                    YAML.load_file("#{RAILS_ROOT}/config/steamcannon.yml")
                  rescue
                    {}
                  end)
