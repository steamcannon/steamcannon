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

cirras_frontend_1_0_0_beta2 =
  Image.find_or_create_by_cloud_id("ami-2749a54e",
                                   :name => "JBoss CirrAS front-end 1.0.0.Beta2",
                                   :image_role => frontend_role)

cirras_backend_1_0_0_beta2 =
  Image.find_or_create_by_cloud_id("ami-5949a530",
                                   :name => "JBoss CirrAS back-end 1.0.0.Beta2",
                                   :image_role => backend_role)

cirras_mgmt_1_0_0_beta2 =
  Image.find_or_create_by_cloud_id("ami-2741ad4e",
                                   :name => "JBoss CirrAS management 1.0.0.Beta2",
                                   :image_role => mgmt_role)


# find_or_create_by syntax was getting horribly verbose at this point
unless Platform.find_by_name("JBoss Community 2-tier")
  platform = Platform.create(:name => "JBoss Community 2-tier")
  platform_version = PlatformVersion.create(:version_number => "1.0.0.Beta2",
                                            :platform => platform)
  frontend = PlatformVersionImage.create(:platform_version => platform_version,
                                         :image => cirras_frontend_1_0_0_beta2)
  backend = PlatformVersionImage.create(:platform_version => platform_version,
                                        :image => cirras_backend_1_0_0_beta2)
  mgmt = PlatformVersionImage.create(:platform_version => platform_version,
                                     :image => cirras_mgmt_1_0_0_beta2)
end
