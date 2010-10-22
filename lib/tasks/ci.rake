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

namespace :ci do
  desc 'Run RSpecs and generate RCov report'
  task :specs => ['db:test:load', 'spec:rcov'] do
  end

  desc 'Package SteamCannon'
  task :package => ['bundle:package', 'bundle:local_deployment',
                    'compile_css', 'create_archive',
                    'bundle:delete_config', 'bundle:delete_vendor_bundle'] do
  end

  task :compile_css do
    ruby_exec("compass compile -c config/compass.rb -r ninesixty")
  end

  task :create_archive do
    Rake::Task['torquebox:archive'].invoke

    # Add bundler config to archive
    `jar uf steamcannon.rails .bundle/config`

    # Add steamcannon.yml to archive
    require 'fileutils'
    FileUtils.mkdir_p('/tmp/config')
    File.open('/tmp/config/steamcannon.yml', 'w') do |file|
      file.write <<-EOF
        deltacloud_url: http://localhost:8080/deltacloud/api
      EOF
    end
    `jar uf steamcannon.rails -C /tmp config/steamcannon.yml`
  end

  desc 'Run CI Build'
  task :run => [:specs, :package] do
  end
end
