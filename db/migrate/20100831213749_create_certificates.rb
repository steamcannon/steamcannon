class CreateCertificates < ActiveRecord::Migration
  def self.up
    create_table :certificates do |t|
      t.string :cert_type
      t.text :certificate
      t.text :keypair
      t.integer :certifiable_id
      t.string :certifiable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :certificates
  end
end
