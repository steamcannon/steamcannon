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
  def perform(payload)
    payload[:class_name].constantize.find(payload[:id]).send(payload[:method], *(payload[:args] || []))
  end

  def self.async(model, method, *args)
    super(:perform, :method => method, :class_name => model.class.name, :id => model.id, :args => args)
  end
end
