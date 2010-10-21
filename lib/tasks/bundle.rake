#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

namespace :bundle do
  task :base do
    require 'rbconfig'
    bindir = RbConfig::CONFIG['bindir']
    ruby = RbConfig::CONFIG['ruby_install_name']
    @bundle_exec = lambda { |arguments|
      puts "#{File.join(bindir, ruby)} -S bundle #{arguments}"
      `#{File.join(bindir, ruby)} -S bundle #{arguments}`
    }
  end

  desc "Delete bundler config file"
  task :delete_config do
    config_file = File.join(File.dirname(__FILE__), '..', '..', '.bundle', 'config')
    `rm -f #{config_file}`
  end

  desc "Delete vendor/bundle directory"
  task :delete_vendor_bundle do
    bundle_dir = File.join(File.dirname(__FILE__), '..', '..', 'vendor', 'bundle')
    ` rm -rf #{bundle_dir}`
  end

  desc "bundle package"
  task :package => :base do
    @bundle_exec.call('package')
  end

  desc "bundle install --deployment --local"
  task :local_deployment => :base do
    @bundle_exec.call('install --deployment --local --without torquebox')
  end
end