module AuditColumns
  module Activation
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # Store controller as thread local for thread-safety
      def controller=(value)
        Thread.current[:audit_columns_controller] = value
      end

      def controller
        Thread.current[:audit_columns_controller]
      end
    end

    module InstanceMethods
      def audit_action(action)
        time_attr = "#{action}_at="
        user_attr = "#{action}_by="
        self.send(time_attr, Time.now) if self.respond_to?(time_attr)
        unless controller.nil? or controller.current_user.nil?
          user = controller.current_user
          self.send(user_attr, user.id) if self.respond_to?(user_attr)
        end
      end

      private
      def controller
        AuditColumns::Base.controller
      end
    end
  end
end
