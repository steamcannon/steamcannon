module AuditColumns
  module ControllerAdapters
    # Adapts audit_columns to work with Rails.
    class RailsAdapter < AbstractAdapter
      class AuditColumnsLoadedTooLateError < StandardError; end

      # Lets audit_columns know about the controller object via a before filter
      module RailsImplementation
        def self.included(klass)
          if defined?(::ApplicationController)
            raise AuditColumnsLoadedTooLateError.new
          end

          klass.prepend_around_filter :activate_audit_columns
        end

        private
        def activate_audit_columns
          AuditColumns::Base.controller = self
          yield
          AuditColumns::Base.controller = nil
        end
      end
    end
  end
end

ActionController::Base.send(:include, AuditColumns::ControllerAdapters::RailsAdapter::RailsImplementation)
