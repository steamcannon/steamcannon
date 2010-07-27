class CreateDeployments < ActiveRecord::Migration
  def self.up
    create_table :deployments do |t|
      t.references :app
      t.references :environment
      t.references :user
      t.string     :datasource

      t.timestamps
    end
  end

  def self.down
    drop_table :deployments
  end
end
