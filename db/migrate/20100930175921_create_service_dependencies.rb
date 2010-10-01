class CreateServiceDependencies < ActiveRecord::Migration
  def self.up
    create_table :service_dependencies do |t|
      t.integer :required_service_id
      t.integer :dependent_service_id

      t.timestamps
    end
  end

  def self.down
    drop_table :service_dependencies
  end
end
