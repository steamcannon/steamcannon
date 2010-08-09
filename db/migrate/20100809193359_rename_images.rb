class Image < ActiveRecord::Base
end

class RenameImages < ActiveRecord::Migration
  def self.up
    frontend = Image.find_by_cloud_id("ami-2749a54e")
    unless frontend.nil?
      frontend.name = "JBoss EWS (Apache)"
      frontend.save!
    end

    backend = Image.find_by_cloud_id("ami-5949a530")
    unless backend.nil?
      backend.name = "JBoss Enterprise Application Platform 5.1"
      backend.save!
    end

    mgmt = Image.find_by_cloud_id("ami-2741ad4e")
    unless mgmt.nil?
      mgmt.name = "JBoss Operations Network 2.4"
      mgmt.save!
    end
  end

  def self.down
    frontend = Image.find_by_cloud_id("ami-2749a54e")
    unless frontend.nil?
      frontend.name = "JBoss CirrAS front-end 1.0.0.Beta2"
      frontend.save!
    end

    backend = Image.find_by_cloud_id("ami-5949a530")
    unless backend.nil?
      backend.name = "JBoss CirrAS back-end 1.0.0.Beta2"
      backend.save!
    end

    mgmt = Image.find_by_cloud_id("ami-2741ad4e")
    unless mgmt.nil?
      mgmt.name = "JBoss CirrAS management 1.0.0.Beta2"
      mgmt.save!
    end
  end
end
