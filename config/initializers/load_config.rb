# set defaults
APP_CONFIG = {
  :use_ssl_with_agents => true,
  :signup_mode => 'open_signup',
  :require_ssl_for_web => false
}

APP_CONFIG.merge!(begin
                    YAML.load_file("#{RAILS_ROOT}/config/steamcannon.yml").symbolize_keys
                  rescue
                    {}
                  end)
