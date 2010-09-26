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

class InstanceService < ActiveRecord::Base
  belongs_to :instance
  belongs_to :service

  def peers(service_name)
    service = Service.find_by_name(service_name)
    environment = instance.environment
    instance_ids = environment.instances.active.map(&:id)
    InstanceService.find(:all, :conditions => {
                           :instance_id => instance_ids,
                           :service_id => service.id
                         })
  end

  def name
    service.name
  end

  #TODO: move this stuff to agent_services, and write tests for it
  def configure
    send("configure_#{name}") if respond_to?("configure_#{name}")
  end

  def verify
    result = instance.agent_client(service).status
    logger.info "################# #{result.inspect}"
    result['state'] and result['state'] == 'started'
  end
  
  protected

  def configure_jboss_as
    config = instance.cloud_specific_hacks.multicast_config
    proxies = peers('mod_cluster')
    unless proxies.empty?
      proxy_list = proxies.inject({}) do |list, proxy_instance|
        dns = proxy_instance.instance.public_dns
        list[dns] = {:host => dns, :port => 80} unless dns.blank?
        list
      end
      config.merge!({:proxy_list => proxy_list})
    end
    instance.agent_client(service.name).configure(config.to_json)
  end

  def configure_mod_cluster
    peers('jboss_as').each(&:configure)
  end

end
