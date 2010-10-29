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


class ModelTask < TorqueBox::Messaging::Task

  # FIXME: this won't handle active_record objects in the args. We
  # should fix if we need that.
  def perform(payload, retry_count = 0)
    payload[:class_name].constantize.find(payload[:id]).send(payload[:method], *(payload[:args] || []))
  rescue ActiveRecord::RecordNotFound => ex
    # use puts to get in to server.log
    puts "ModelTask#perform: FAILED to find record: #{ex}"
    if retry_count < 3
      retry_count += 1
      puts "ModelTask#perform: retrying after 1 second sleep (retry_count: #{retry_count})"
      sleep(1)
      perform(payload, retry_count)
    else
      puts "ModelTask#perform: giving up"
    end
  end

  class << self
    alias_method :async_orig, :async
  end
  def self.fake(id)
    async_orig(:perform, :method => :nil?, :class_name => 'Deployment', :id => id, :args => [])
  end
  
  def self.async(model, method, *args)
    super(:perform, :method => method, :class_name => model.class.name, :id => model.id, :args => args)
  end
end
