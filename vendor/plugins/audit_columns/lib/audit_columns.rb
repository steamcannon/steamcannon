# TODO: Pull this out into a standalone gem

AUDIT_COLUMNS_PATH ||= File.dirname(__FILE__) + "/audit_columns/"

[
 "base",
 "controller_adapters/abstract_adapter"
].each do |library|
  require AUDIT_COLUMNS_PATH + library
end

# TODO: Support more than just Rails
require AUDIT_COLUMNS_PATH + "controller_adapters/rails_adapter" if defined?(Rails)

module AuditColumns
  def self.included(klass)
    klass.class_eval do
      include AuditColumns::Base
    end
  end
end
