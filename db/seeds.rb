# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

frontend_role = ImageRole.find_or_create_by_name("frontend")
backend_role = ImageRole.find_or_create_by_name("backend")
mgmt_role = ImageRole.find_or_create_by_name("management")
db_role = ImageRole.find_or_create_by_name("database")

frontend_image =
  Image.find_or_create_by_cloud_id("ami-2749a54e",
                                   :name => "JBoss EWS (Apache)",
                                   :image_role => frontend_role)

backend_image =
  Image.find_or_create_by_cloud_id("ami-5949a530",
                                   :name => "JBoss Enterprise Application Platform 5.1",
                                   :image_role => backend_role)

mgmt_image =
  Image.find_or_create_by_cloud_id("ami-2741ad4e",
                                   :name => "JBoss Operations Network 2.4",
                                   :image_role => mgmt_role)

db_image =
  Image.find_or_create_by_image_role_id(db_role.id,
                                        :cloud_id => "ami-12345",
                                        :name => "PostgreSQL 8.4")




# find_or_create_by syntax was getting horribly verbose at this point
unless Platform.find_by_name("JBoss Enterprise 2-Tier")
  platform = Platform.create(:name => "JBoss Enterprise 2-Tier")
  platform_version = PlatformVersion.create(:version_number => "",
                                            :platform => platform)
  frontend = PlatformVersionImage.create(:platform_version => platform_version,
                                         :image => frontend_image)
  backend = PlatformVersionImage.create(:platform_version => platform_version,
                                        :image => backend_image)
  mgmt = PlatformVersionImage.create(:platform_version => platform_version,
                                     :image => mgmt_image)
  db = PlatformVersionImage.create(:platform_version => platform_version,
                                   :image => db_image)
end
