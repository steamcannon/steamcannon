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

module HasEvents
  class << self
    attr_writer :log_event_on_state_transition
    
    def log_event_on_state_transition
      @log_event_on_state_transition = true if @log_event_on_state_transition.nil?
      @log_event_on_state_transition
    end
  end
  
  module InstanceMethods

    def log_event(options)
      Event.create(options.merge(:event_subject => subject))
    end

    def aasm_log_state_transition
      log_event(:operation => :state_transition, :status => aasm_current_state, :error => last_error) if HasEvents.log_event_on_state_transition
    end

    protected
    def subject
      HasEvents::Util.update_or_create_subject(self)
    end
  end

  module Util
    class << self
      def update_or_create_subject(object)
        return nil unless object
        subject = object.event_subject
        if subject
          name = extract_option(:subject_name, object)
          subject.update_attribute(:name, name) unless subject.name == name
          subject
        else
          create_subject(object)
        end
      end

      def create_subject(object)
        object.create_event_subject(:name => extract_option(:subject_name, object),
                                    :parent => update_or_create_subject(extract_option(:subject_parent, object)),
                                    :owner => extract_option(:subject_owner, object))
      end

      def extract_option(key, object)
        value = object.class.has_events_options[key]
        if value.respond_to?(:call)
          value.call(object)
        elsif value
          object.__send__(value)
        end
      end
    end
  end
  
  module ActiveRecordSupport
    def has_events(options)
      has_one :event_subject, :as => :subject
      has_many :events, :through => :event_subject
      [:subject_name, :subject_owner].each do |opt|
        raise RuntimeError.new("has_events requires the #{opt} option") unless options[opt]
      end
      @has_events_options = options
      singleton_class.__send__(:attr_reader, :has_events_options)
      include HasEvents::InstanceMethods
    end
  end

  module AASMSupport
    attr_reader :on_transition

    def self.included(base)
      base.alias_method_chain(:initialize, :has_event)
      base.alias_method_chain(:_call_action, :has_event)
    end

    # Add the log state transition method to every state after_enter
    def initialize_with_has_event(name, opts = {})
      opts[:after_enter] = [opts[:after_enter]].compact unless opts[:after_enter].is_a?(Array)
      opts[:after_enter].unshift(:aasm_log_state_transition) unless opts[:after_enter].include?(:aasm_log_state_transition)
      initialize_without_has_event(name, opts)
    end

    # since we instrument *every* state, we have to weed
    # out the actions on classes where aasm_log_state_transistion
    # does not exist. A better solution would be to have a way to
    # access the class where the state is being defined.
    def _call_action_with_has_event(action, record)
      if action != :aasm_log_state_transition or
          record.respond_to?(action)
        _call_action_without_has_event(action, record)
      end
    end
  end
end


AASM::SupportingClasses::State.__send__(:include, HasEvents::AASMSupport) unless AASM::SupportingClasses::State.include?(HasEvents::AASMSupport)
ActiveRecord::Base.__send__(:extend, HasEvents::ActiveRecordSupport) unless ActiveRecord::Base.include?(HasEvents::ActiveRecordSupport)

