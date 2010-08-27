module AuditColumns
  module ControllerAdapters
    class AbstractAdapter
      attr_accessor :controller

      def initialize(controller)
        self.controller = controller
      end
    end
  end
end
