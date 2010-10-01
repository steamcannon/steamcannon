# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Service.load_from_yaml_file('db/fixtures/services/jboss_services.yml')

unless Platform.find_by_name("JBoss Enterprise 3-Tier")
  Platform.create_from_yaml_file("db/fixtures/platforms/jboss_enterprise_3_tier.yml")
end
unless Platform.find_by_name("JBoss 2 Tier")
  Platform.create_from_yaml_file("db/fixtures/platforms/jboss_2_tier.yml")
end
unless Platform.find_by_name("Single Tier")
  Platform.create_from_yaml_file("db/fixtures/platforms/single_tier.yml")
end


